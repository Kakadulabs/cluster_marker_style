# cluster_marker_style_gmcm

One-line, cached, count-aware cluster icons for
[`google_maps_cluster_manager_2`](https://pub.dev/packages/google_maps_cluster_manager_2),
powered by [`cluster_marker_style`](https://pub.dev/packages/cluster_marker_style).

`google_maps_cluster_manager_2` decides which markers group together; this
package draws the cluster icons — rendered sharply at the device pixel ratio,
cached, and colored/sized by count.

## Install

```yaml
dependencies:
  cluster_marker_style_gmcm: ^0.1.0
  google_maps_flutter: ^2.9.0
  google_maps_cluster_manager_2: ^3.0.0
```

## Use

```dart
import 'package:cluster_marker_style_gmcm/cluster_marker_style_gmcm.dart';

// Create once and reuse — the renderer holds the icon cache.
final renderer = ClusterRenderer(ClusterStyle.soft());

ClusterManager<Place>(
  places,
  _updateMarkers,
  markerBuilder: clusterMarkerBuilder(
    renderer: renderer,
    devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
    onTap: (cluster) => debugPrint('Tapped ${cluster.count}'),
    // singleItemBuilder: (cluster) async => ...  // optional override
  ),
);
```

This library re-exports `cluster_marker_style`, so `ClusterStyle`,
`ClusterRenderer`, `CountTier` and the rest are available from the one import.
See the [`cluster_marker_style` README](https://pub.dev/packages/cluster_marker_style)
for styling options.

## License

MIT — see [LICENSE](LICENSE).
