import 'package:cluster_marker_style/cluster_marker_style.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const style = ClusterStyle(
    tiers: <CountTier>[
      CountTier(upTo: 10, color: Color(0xFF000001)),
      CountTier(upTo: 100, color: Color(0xFF000002)),
      CountTier(upTo: 1000, color: Color(0xFF000003)),
    ],
    minDiameter: 30,
    maxDiameter: 80,
  );

  group('tierFor', () {
    test('upTo is inclusive', () {
      expect(tierFor(style, 10).upTo, 10);
      expect(tierFor(style, 100).upTo, 100);
    });

    test('crossing a boundary selects the next tier', () {
      expect(tierFor(style, 1).upTo, 10);
      expect(tierFor(style, 11).upTo, 100);
      expect(tierFor(style, 101).upTo, 1000);
    });

    test('counts above the last tier fall back to it', () {
      expect(tierFor(style, 999999).upTo, 1000);
    });
  });

  group('sizeFor', () {
    test('clamps to minDiameter for tiny clusters', () {
      expect(sizeFor(style, 1), 30);
    });

    test('grows monotonically with count', () {
      expect(sizeFor(style, 5), lessThan(sizeFor(style, 50)));
      expect(sizeFor(style, 50), lessThan(sizeFor(style, 900)));
    });

    test('caps at maxDiameter for huge clusters', () {
      expect(sizeFor(style, 1000000), 80);
    });

    test('an explicit tier size overrides the curve', () {
      const pinned = ClusterStyle(
        tiers: <CountTier>[
          CountTier(upTo: 1000, color: Color(0xFF000004), size: 55),
        ],
      );
      expect(sizeFor(pinned, 7), 55);
      expect(sizeFor(pinned, 800), 55);
    });
  });
}
