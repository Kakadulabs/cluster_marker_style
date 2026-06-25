import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../cache/cluster_icon_cache.dart';
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

  /// The icon cache. A default unbounded cache is created if none is supplied.
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

  Future<BitmapDescriptor> _render({
    required CountTier tier,
    required double diameter,
    required String label,
    required double devicePixelRatio,
  }) async {
    final shadow = style.shadow;
    final borderWidth = style.border?.width ?? 0.0;
    final shadowExtent = shadow?.extent ?? 0.0;

    // Logical canvas leaves room for the half of the stroke that extends
    // outward, the shadow spread, and 1px of anti-alias safety.
    final margin = (borderWidth / 2) + shadowExtent + 1;
    final logicalCanvas = diameter + margin * 2;
    final physical = math.max(1, (logicalCanvas * devicePixelRatio).round());

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    // Author everything in logical units; the scale handles DPI.
    canvas.scale(devicePixelRatio);

    final center = Offset(logicalCanvas / 2, logicalCanvas / 2);
    final radius = diameter / 2;

    // 1. Shadow.
    if (shadow != null) {
      final paint = ui.Paint()
        ..color = shadow.color
        ..maskFilter =
            ui.MaskFilter.blur(ui.BlurStyle.normal, _sigmaForBlur(shadow.blur));
      canvas.drawCircle(center + shadow.offset, radius, paint);
    }

    // 2. Shape fill.
    final fillPaint = ui.Paint()
      ..color = tier.color
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius, fillPaint);

    // 3. Border ring (stroke centered on the circle's edge).
    if (style.border != null && borderWidth > 0) {
      final borderColor = tier.borderColor ?? style.border!.color;
      final strokePaint = ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..color = borderColor
        ..isAntiAlias = true;
      canvas.drawCircle(center, radius, strokePaint);
    }

    // 4. Count text, fitted within the padded interior.
    final textColor = tier.textColor ?? style.textStyle.color;
    final maxTextWidth = math.max(1.0, diameter - style.padding.horizontal);
    final maxTextHeight = math.max(1.0, diameter - style.padding.vertical);
    final painter = _layoutLabel(label, textColor, maxTextWidth, maxTextHeight);
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );

    // Rasterize at physical resolution, then free GPU resources.
    final picture = recorder.endRecording();
    ui.Image? image;
    try {
      image = await picture.toImage(physical, physical);
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

  // Matches Flutter's BoxShadow blur-radius -> Gaussian sigma conversion.
  static double _sigmaForBlur(double blur) => blur * 0.57735 + 0.5;
}
