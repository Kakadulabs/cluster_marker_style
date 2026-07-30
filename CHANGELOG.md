## 0.3.0

- **Fix: drop shadows were clipped.** `ClusterShadow.extent` reserved only
  `blur + offset.distance` of canvas margin, but a Gaussian blur stays visible
  out to roughly three sigma — so the soft edge of the shadow was cut off. The
  reach is now `3 * sigma + offset.distance`, and the sigma conversion is
  exposed as `ClusterShadow.sigma` instead of being duplicated inside the
  renderer. Shadowed icons rasterize to a slightly larger bitmap; the shape
  stays centered, so marker anchoring is unchanged.
- **Fix: `flusterMarkers(...)` built markers one at a time.** Each cluster icon
  was awaited in sequence, so a viewport of N clusters serialized N
  rasterizations. Markers are now built concurrently via `Future.wait` and are
  still returned in the order the items were given.
- **Fix: `ClusterStyle.copyWith` could not clear `border` or `shadow`.** Passing
  `null` keeps the current value (that is what a missing `copyWith` argument
  means), which made "`ClusterStyle.soft()` without its shadow" impossible to
  express. Added `removeBorder` / `removeShadow` flags:
  `ClusterStyle.soft().copyWith(removeShadow: true)`.
- **Fix: `ClusterIconCache` was unbounded by default.** It now caps at
  `kDefaultClusterIconCacheSize` (256) entries with LRU eviction, so a long
  session that keeps producing new visual outcomes (a changing device pixel
  ratio, a formatter that emits a unique label per count) can't grow it without
  bound. Use `ClusterIconCache.unbounded()` for the old behavior. A cache hit
  now also refreshes recency regardless of whether a cap is set.
- Tests: added coverage for the `google_maps_cluster_manager_2` adapter, which
  previously had none, plus shadow geometry, the `copyWith` flags, cache
  eviction order, and fluster marker ordering.

## 0.2.0

- Add a `fluster` adapter (`package:cluster_marker_style/cluster_marker_style_fluster.dart`):
  `flusterMarkers(...)` and `flusterClusterMarkers(...)` turn
  `Fluster.clusters(bbox, zoom)` results into styled, cached map markers. fluster
  supplies only the clustering algorithm; this package renders the cluster icons.
- Cluster markers from both adapters are now center-anchored
  (`Offset(0.5, 0.5)`), so the bubble sits on the cluster location instead of
  above it.
- Example app gains a runnable fluster demo
  (`flutter run -t lib/fluster_example.dart`).

## 0.1.0

Initial release.

- `ClusterStyle` with value equality and three polished named styles
  (`.soft`, `.flat`, `.outlined`).
- `CountTier` count-aware color/size buckets and a logarithmic size curve.
- `CountFormatter` with a good-looking `DefaultCountFormatter`
  (e.g. `1500 -> "1.5k"`, optional `"N+"` cap).
- `ClusterRenderer`: device-correct `PictureRecorder`/`Canvas`/`TextPainter`
  pipeline that disposes its `ui.Image` and emits a `BitmapDescriptor` via
  `imagePixelRatio`.
- `ClusterIconCache` with visual-outcome cache keys, in-flight de-duplication,
  optional LRU eviction, and `clear()`.
- One-line `clusterMarkerBuilder(...)` adapter for
  `google_maps_cluster_manager_2`, in a separate library so the core stays
  independent of it.
- Runnable example app with a live style switcher.
