import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../style/cluster_style.dart';
import '../style/count_tier.dart';

/// Identifies a cluster icon by its **visual outcome**, not its raw count.
///
/// Two counts share a key — and therefore one cached bitmap — only when they
/// produce the same drawing: same style, same tier, same label, same diameter,
/// and same device pixel ratio. So a cluster of 47 and 48 share a bitmap when
/// they look identical, but counts that cross a tier boundary, change the
/// rendered label, or change the derived size do not.
@immutable
class ClusterCacheKey {
  const ClusterCacheKey({
    required this.style,
    required this.tier,
    required this.label,
    required this.diameterKey,
    required this.dprKey,
  });

  /// Builds a key from the visual ingredients. [diameter] and
  /// [devicePixelRatio] are quantized so float noise doesn't fragment the
  /// cache (0.5 px and 0.01 dpr buckets).
  factory ClusterCacheKey.of({
    required ClusterStyle style,
    required CountTier tier,
    required String label,
    required double diameter,
    required double devicePixelRatio,
  }) {
    return ClusterCacheKey(
      style: style,
      tier: tier,
      label: label,
      diameterKey: (diameter * 2).round(),
      dprKey: (devicePixelRatio * 100).round(),
    );
  }

  final ClusterStyle style;
  final CountTier tier;
  final String label;

  /// Diameter quantized to 0.5 logical-px buckets.
  final int diameterKey;

  /// Device pixel ratio quantized to 0.01 buckets.
  final int dprKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClusterCacheKey &&
          other.style == style &&
          other.tier == tier &&
          other.label == label &&
          other.diameterKey == diameterKey &&
          other.dprKey == dprKey;

  @override
  int get hashCode => Object.hash(style, tier, label, diameterKey, dprKey);
}

/// In-memory cache of rendered cluster icons.
///
/// This is the single most important feature for a smooth map: without it,
/// every camera movement re-rasterizes bitmaps and the map janks. The cache
/// stores the build [Future] (not just the result), so a burst of identical
/// requests during a fast pan all await one rasterization.
///
/// Pass [maxSize] to cap the number of cached entries with simple
/// least-recently-used eviction. Leave it null for an unbounded cache (fine for
/// most apps — there are only as many entries as distinct visual outcomes).
class ClusterIconCache {
  ClusterIconCache({this.maxSize})
      : assert(maxSize == null || maxSize > 0, 'maxSize must be positive');

  /// Maximum number of entries before LRU eviction kicks in. Null = unbounded.
  final int? maxSize;

  // LinkedHashMap preserves insertion order; we re-insert on access so the
  // first key is always the least-recently-used.
  final Map<ClusterCacheKey, Future<BitmapDescriptor>> _entries =
      <ClusterCacheKey, Future<BitmapDescriptor>>{};

  /// Returns the cached icon for [key], building (and caching) it on a miss.
  Future<BitmapDescriptor> getOrCreate({
    required ClusterCacheKey key,
    required Future<BitmapDescriptor> Function() build,
  }) {
    final existing = _entries[key];
    if (existing != null) {
      if (maxSize != null) {
        // Mark most-recently-used.
        _entries.remove(key);
        _entries[key] = existing;
      }
      return existing;
    }

    final future = _guarded(key, build);
    _entries[key] = future;
    _evictIfNeeded();
    return future;
  }

  Future<BitmapDescriptor> _guarded(
    ClusterCacheKey key,
    Future<BitmapDescriptor> Function() build,
  ) async {
    try {
      return await build();
    } catch (_) {
      // Don't cache a failed build — let the next request retry.
      _entries.remove(key);
      rethrow;
    }
  }

  void _evictIfNeeded() {
    final cap = maxSize;
    if (cap == null) return;
    while (_entries.length > cap) {
      _entries.remove(_entries.keys.first);
    }
  }

  /// Number of cached entries.
  int get length => _entries.length;

  /// Drops all cached icons. Call when the style changes at runtime.
  void clear() => _entries.clear();
}
