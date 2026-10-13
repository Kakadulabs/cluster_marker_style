import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../cache/cluster_icon_cache.dart';
import '../style/cluster_shape.dart';
import '../style/cluster_style.dart';
import '../style/count_tier.dart';
import '../style/tier_selection.dart';

/// Renders a [ClusterStyle] into a `BitmapDescriptor` for a given count and
/// device pixel ratio, using a `PictureRecorder` / `Canvas` / `TextPainter`
/// pipeline.
///
/// Pass a [ClusterIconCache] to avoid re-rasterizing identical icons as the
/// camera moves — this is what keeps a dense map smooth. Reuse one renderer
/// instance for the lifetime of a style.
class ClusterRenderer {
  ClusterRenderer(this.style, {ClusterIconCache? cache})
      : cache = cache ?? ClusterIconCache();

  /// The style this renderer draws.
  final ClusterStyle style;

  /// The icon cache. A default one (capped at
  /// [kDefaultClusterIconCacheSize] entries) is created if none is supplied.
  final ClusterIconCache cache;

  /// Returns a (cached) `BitmapDescriptor` for [count] at [devicePixelRatio].
  ///
  /// [devicePixelRatio] should come from `MediaQuery.of(context)
  /// .devicePixelRatio`. It is used both to rasterize at native resolution
  /// (sharp on high-DPI screens) and as part of the cache key.
  Future<BitmapDescriptor> bitmapFor({
    required int count,
    required double devicePixelRatio,
  }) {
    final tier = tierFor(style, count);
    final diameter = sizeFor(style, count);
    final label = style.countFormatter.format(count);

    final key = ClusterCacheKey.of(
      style: style,
      tier: tier,
      label: label,
      diameter: diameter,
      devicePixelRatio: devicePixelRatio,
    );

    return cache.getOrCreate(
      key: key,
      build: () => _render(
        tier: tier,
        diameter: diameter,
        label: label,
        devicePixelRatio: devicePixelRatio,
      ),
    );
  }

  /// Renders and caches the icons for [counts] ahead of time, so the first
  /// frame of the map doesn't wait on rasterization and icons don't pop in.
  ///
  /// Call it once you know the device pixel ratio — for example from
  /// `didChangeDependencies` — before the clustered markers are first built:
  ///
  /// ```dart
  /// renderer.precache(
  ///   counts: List.generate(99, (i) => i + 2), // every cluster up to 100
  ///   devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
  /// );
  /// ```
  ///
  /// Counts that produce the same icon are rendered once. Icons beyond the
  /// cache's [ClusterIconCache.maxSize] evict earlier ones, so keep [counts]
  /// within it.
  Future<void> precache({
    required Iterable<int> counts,
    required double devicePixelRatio,
  }) {
    return Future.wait(
      counts.map(
        (count) => bitmapFor(count: count, devicePixelRatio: devicePixelRatio),
      ),
    );
  }

  Future<BitmapDescriptor> _render({
    required CountTier tier,
    required double diameter,
    required String label,
    required double devicePixelRatio,
  }) async {
    final shadow = style.shadow;
    final borderWidth = style.border?.width ?? 0.0;
    final shadowExtent = shadow?.extent ?? 0.0;

    // Lay the label out first: a pill's width depends on it.
    final textColor = tier.textColor ?? style.textStyle.color;
    final isPill = style.shape == ClusterShape.pill;
    final maxTextHeight = math.max(1.0, diameter - style.padding.vertical);
    // A circle fits the label within its padded interior; a pill only
    // constrains the height and grows sideways instead.
    final maxTextWidth = isPill
        ? double.infinity
        : math.max(1.0, diameter - style.padding.horizontal);
    final painter = _layoutLabel(label, textColor, maxTextWidth, maxTextHeight);
    final shapeWidth =
        isPill ? pillWidthFor(style, diameter, painter.width) : diameter;

    // Logical canvas leaves room for the half of the stroke that extends
    // outward, the shadow spread, and 1px of anti-alias safety.
    final margin = (borderWidth / 2) + shadowExtent + 1;
    final logicalWidth = shapeWidth + margin * 2;
    final logicalHeight = diameter + margin * 2;
    final physicalWidth =
        math.max(1, (logicalWidth * devicePixelRatio).round());
    final physicalHeight =
        math.max(1, (logicalHeight * devicePixelRatio).round());

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    // Author everything in logical units; the scale handles DPI.
    canvas.scale(devicePixelRatio);

    final center = Offset(logicalWidth / 2, logicalHeight / 2);
    // A circle is the stadium whose width equals its height, so one rounded
    // rect draws both shapes.
    final shape = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: shapeWidth, height: diameter),
      Radius.circular(diameter / 2),
    );

    // 1. Shadow.
    if (shadow != null) {
      final paint = ui.Paint()
        ..color = shadow.color
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, shadow.sigma);
      canvas.drawRRect(shape.shift(shadow.offset), paint);
    }

    // 2. Shape fill.
    final fillPaint = ui.Paint()
      ..color = tier.color
      ..isAntiAlias = true;
    canvas.drawRRect(shape, fillPaint);

    // 3. Border ring (stroke centered on the shape's edge).
    if (style.border != null && borderWidth > 0) {
      final borderColor = tier.borderColor ?? style.border!.color;
      final strokePaint = ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..color = borderColor
        ..isAntiAlias = true;
      canvas.drawRRect(shape, strokePaint);
    }

    // 4. Count text, centered.
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );

    // Rasterize at physical resolution, then free GPU resources.
    final picture = recorder.endRecording();
    ui.Image? image;
    try {
      image = await picture.toImage(physicalWidth, physicalHeight);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Failed to encode cluster icon to PNG bytes.');
      }
      final bytes = byteData.buffer.asUint8List();
      return _toDescriptor(bytes, devicePixelRatio);
    } finally {
      image?.dispose();
      picture.dispose();
    }
  }

  TextPainter _layoutLabel(
    String label,
    Color color,
    double maxWidth,
    double maxHeight,
  ) {
    final ts = style.textStyle;

    TextPainter build(double fontSize) {
      return TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: ts.fontWeight,
            fontFamily: ts.fontFamily,
            letterSpacing: ts.letterSpacing,
            height: 1.0,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 1,
      )..layout();
    }

    // Start at the max size; shrink to fit, clamped to the min size.
    var painter = build(ts.maxFontSize);
    if (painter.width > maxWidth || painter.height > maxHeight) {
      final scale =
          math.min(maxWidth / painter.width, maxHeight / painter.height);
      final fitted =
          (ts.maxFontSize * scale).clamp(ts.minFontSize, ts.maxFontSize);
      painter = build(fitted.toDouble());
    }
    return painter;
  }

  BitmapDescriptor _toDescriptor(Uint8List bytes, double devicePixelRatio) {
    // The bitmap is rasterized at (logical * dpr) physical px. Passing
    // imagePixelRatio lets google_maps_flutter display the icon at its intended
    // logical size while keeping it sharp on high-DPI screens — handled
    // uniformly across Android, iOS, and web by the plugin.
    return BitmapDescriptor.bytes(bytes, imagePixelRatio: devicePixelRatio);
  }
}
