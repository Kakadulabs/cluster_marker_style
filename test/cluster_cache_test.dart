import 'package:cluster_marker_style/cluster_marker_style.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  const style = ClusterStyle(
    tiers: <CountTier>[
      CountTier(upTo: 100, color: Color(0xFF112233)),
      CountTier(upTo: 1 << 30, color: Color(0xFF445566)),
    ],
  );
  final tierA = style.tiers[0];
  final tierB = style.tiers[1];

  ClusterCacheKey keyOf({
    CountTier? tier,
    String label = '50',
    double diameter = 50,
    double dpr = 2,
  }) {
    return ClusterCacheKey.of(
      style: style,
      tier: tier ?? tierA,
      label: label,
      diameter: diameter,
      devicePixelRatio: dpr,
    );
  }

  group('ClusterCacheKey (visual-outcome keys)', () {
    test('identical visual outcome => equal key and hash', () {
      expect(keyOf(), keyOf());
      expect(keyOf().hashCode, keyOf().hashCode);
    });

    test('small float noise in diameter shares a key', () {
      expect(keyOf(diameter: 50.0), keyOf(diameter: 50.2));
    });

    test('crossing a tier boundary => different key', () {
      expect(keyOf(tier: tierA) == keyOf(tier: tierB), isFalse);
    });

    test('different label => different key', () {
      expect(keyOf(label: '50') == keyOf(label: '51'), isFalse);
    });

    test('different diameter bucket => different key', () {
      expect(keyOf(diameter: 50) == keyOf(diameter: 60), isFalse);
    });

    test('different device pixel ratio => different key', () {
      expect(keyOf(dpr: 2) == keyOf(dpr: 3), isFalse);
    });
  });

  group('ClusterIconCache', () {
    Future<BitmapDescriptor> stub() async => BitmapDescriptor.defaultMarker;

    test('dedupes identical keys (builds once)', () async {
      final cache = ClusterIconCache();
      var builds = 0;
      Future<BitmapDescriptor> counting() async {
        builds++;
        return BitmapDescriptor.defaultMarker;
      }

      final k = keyOf(label: '7', diameter: 40);
      await cache.getOrCreate(key: k, build: counting);
      await cache.getOrCreate(key: k, build: counting);

      expect(builds, 1);
      expect(cache.length, 1);
    });

    test('distinct keys create distinct entries', () async {
      final cache = ClusterIconCache();
      await cache.getOrCreate(key: keyOf(label: '1'), build: stub);
      await cache.getOrCreate(key: keyOf(label: '2'), build: stub);
      expect(cache.length, 2);
    });

    test('LRU eviction respects maxSize', () async {
      final cache = ClusterIconCache(maxSize: 2);
      await cache.getOrCreate(key: keyOf(label: 'a'), build: stub);
      await cache.getOrCreate(key: keyOf(label: 'b'), build: stub);
      await cache.getOrCreate(key: keyOf(label: 'c'), build: stub);
      expect(cache.length, 2);
    });

    test('clear empties the cache', () async {
      final cache = ClusterIconCache();
      await cache.getOrCreate(key: keyOf(label: '1'), build: stub);
      cache.clear();
      expect(cache.length, 0);
    });
  });
}
