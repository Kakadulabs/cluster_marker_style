import 'dart:ui' as ui;

import 'package:cluster_marker_style/cluster_marker_style.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A formatter with full-length labels, to force wide text.
class _Verbose extends CountFormatter {
  const _Verbose();

  @override
  String format(int count) => '$count points';
}

Future<ui.Image> _decode(BitmapDescriptor descriptor) async {
  final codec = await ui.instantiateImageCodec(
    (descriptor as BytesMapBitmap).byteData,
  );
  return (await codec.getNextFrame()).image;
}

void main() {
  group('pillWidthFor', () {
    final style = ClusterStyle.flat(); // 8px padding: 16 horizontal.

    test('is never narrower than tall', () {
      expect(pillWidthFor(style, 40, 4), 40);
    });

    test('adds at least half the height of clearance', () {
      expect(pillWidthFor(style, 40, 100), 100 + 20);
    });

    test('honors horizontal padding larger than half the height', () {
      final padded = style.copyWith(padding: const EdgeInsets.all(30));
      expect(pillWidthFor(padded, 40, 100), 100 + 60);
    });
  });

  testWidgets('a pill widens for long labels instead of shrinking them',
      (tester) async {
    await tester.runAsync(() async {
      final base = ClusterStyle.flat().copyWith(
        countFormatter: const _Verbose(),
        removeShadow: true,
      );
      final circle = await _decode(
        await ClusterRenderer(base).bitmapFor(count: 50, devicePixelRatio: 1),
      );
      final pill = await _decode(
        await ClusterRenderer(base.copyWith(shape: ClusterShape.pill))
            .bitmapFor(count: 50, devicePixelRatio: 1),
      );

      expect(circle.width, circle.height);
      expect(pill.height, circle.height);
      expect(pill.width, greaterThan(pill.height));
    });
  });

  testWidgets('a pill with a short label is a circle', (tester) async {
    await tester.runAsync(() async {
      // Test-font glyphs are as wide as the font size (wider than real digits),
      // so leave enough height that one glyph clearly fits.
      final style = ClusterStyle.flat(minDiameter: 60).copyWith(
        shape: ClusterShape.pill,
      );
      final image = await _decode(
        await ClusterRenderer(style).bitmapFor(count: 3, devicePixelRatio: 2),
      );
      expect(image.width, image.height);
    });
  });

  testWidgets('pill and circle icons never share a cache entry',
      (tester) async {
    await tester.runAsync(() async {
      final cache = ClusterIconCache();
      final soft = ClusterStyle.soft();
      await ClusterRenderer(soft, cache: cache)
          .bitmapFor(count: 3, devicePixelRatio: 2);
      await ClusterRenderer(soft.copyWith(shape: ClusterShape.pill),
              cache: cache)
          .bitmapFor(count: 3, devicePixelRatio: 2);
      expect(cache.length, 2);
    });
  });
}
