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
