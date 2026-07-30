import 'package:cluster_marker_style/cluster_marker_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClusterShadow geometry', () {
    test('sigma matches Flutter\'s blur-radius conversion', () {
      const shadow = ClusterShadow(blur: 8);
      expect(shadow.sigma, closeTo(8 * 0.57735 + 0.5, 1e-9));
    });

    test('extent covers the full Gaussian reach, not just the blur radius', () {
      const shadow = ClusterShadow(blur: 8, offset: Offset(0, 3));
      // A Gaussian is visually done at ~3 sigma; the old `blur + offset`
      // formula under-reserved the canvas and clipped the shadow's tail.
      expect(shadow.extent, greaterThanOrEqualTo(3 * shadow.sigma));
      expect(shadow.extent, greaterThan(shadow.blur + shadow.offset.distance));
    });

    test('extent accounts for how far the offset pushes the shadow', () {
      const centered = ClusterShadow(blur: 6);
      const pushed = ClusterShadow(blur: 6, offset: Offset(0, 10));
      expect(pushed.extent - centered.extent, closeTo(10 - 2, 1e-9));
    });

    test('a bigger blur reserves more room', () {
      const small = ClusterShadow(blur: 2, offset: Offset.zero);
      const big = ClusterShadow(blur: 20, offset: Offset.zero);
      expect(big.extent, greaterThan(small.extent));
    });

    test('the named styles reserve room for their own shadows', () {
      for (final style in [ClusterStyle.soft(), ClusterStyle.outlined()]) {
        final shadow = style.shadow!;
        expect(shadow.extent, greaterThanOrEqualTo(3 * shadow.sigma));
      }
    });
  });
}
