import 'package:cluster_marker_style/cluster_marker_style.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  testWidgets('renders a bitmap and caches by visual outcome', (tester) async {
    await tester.runAsync(() async {
      final renderer = ClusterRenderer(ClusterStyle.soft());

      final descriptor =
          await renderer.bitmapFor(count: 7, devicePixelRatio: 2);
      expect(descriptor, isA<BitmapDescriptor>());
      expect(renderer.cache.length, 1);

      // Same count is served from cache (no new entry).
      await renderer.bitmapFor(count: 7, devicePixelRatio: 2);
      expect(renderer.cache.length, 1);

      // A different label produces a new entry.
      await renderer.bitmapFor(count: 8, devicePixelRatio: 2);
      expect(renderer.cache.length, 2);
    });
  });

  testWidgets('renders every default style across a wide count range',
      (tester) async {
    await tester.runAsync(() async {
      final styles = [
        ClusterStyle.soft(),
        ClusterStyle.flat(),
        ClusterStyle.outlined(),
      ];
      for (final style in styles) {
        final renderer = ClusterRenderer(style);
        for (final count in [1, 25, 250, 5000, 1000000]) {
          final descriptor =
              await renderer.bitmapFor(count: count, devicePixelRatio: 3);
          expect(descriptor, isA<BitmapDescriptor>());
        }
      }
    });
  });
}
