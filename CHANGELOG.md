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
