# cluster_marker_style_fluster

Styled, cached, count-aware cluster markers for the
[`fluster`](https://pub.dev/packages/fluster) clustering algorithm, powered by
[`cluster_marker_style`](https://pub.dev/packages/cluster_marker_style).

fluster only runs the clustering *algorithm*: `Fluster.clusters(bbox, zoom)`
returns a flat list where `isCluster` marks an aggregate, with no rendering at
all. This package turns that list into map `Marker`s — cluster icons are drawn
and cached for you, and individual points go to your own builder.

## Install

```yaml
dependencies:
  cluster_marker_style_fluster: ^0.1.0
  google_maps_flutter: ^2.9.0
  fluster: ^1.2.0
```

## Use

```dart
import 'package:cluster_marker_style_fluster/cluster_marker_style_fluster.dart';

// Create once and reuse — the renderer holds the icon cache.
final renderer = ClusterRenderer(ClusterStyle.soft());

final markers = await flusterClusterMarkers<MapMarker>(
  fluster: fluster,
  bounds: [westLng, southLat, eastLng, northLat],
  zoom: zoom.round(),
  renderer: renderer,
  devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
  pointMarkerBuilder: (p) async => Marker(
    markerId: MarkerId(p.markerId!),
    position: LatLng(p.latitude!, p.longitude!),
  ),
);
```

Already have the `clusters(...)` result? Pass it to `flusterMarkers(items: ...)`
instead. Markers are built concurrently and returned in input order.

This library re-exports `cluster_marker_style`, so `ClusterStyle`,
`ClusterRenderer`, `CountTier` and the rest are available from the one import.

## License

MIT — see [LICENSE](LICENSE).
