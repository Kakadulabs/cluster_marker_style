# cluster_marker_style

Beautiful, count-aware, **cached** cluster marker icons for Google Maps — a
one-line drop-in for any clustering algorithm.

This repository holds three packages:

| Package | What it is |
| --- | --- |
| [`cluster_marker_style`](packages/cluster_marker_style) | The core: styles, renderer, and icon cache. Depends only on `google_maps_flutter`. |
| [`cluster_marker_style_gmcm`](packages/cluster_marker_style_gmcm) | Adapter for [`google_maps_cluster_manager_2`](https://pub.dev/packages/google_maps_cluster_manager_2). |
| [`cluster_marker_style_fluster`](packages/cluster_marker_style_fluster) | Adapter for [`fluster`](https://pub.dev/packages/fluster). |

Start with the [core README](packages/cluster_marker_style/README.md). The
runnable demo is in
[`packages/cluster_marker_style/example`](packages/cluster_marker_style/example).

## Development

Each adapter has a `pubspec_overrides.yaml` pointing it at the local core, so
changes are tested together. Run per package:

```sh
cd packages/<package>
flutter pub get
flutter analyze
flutter test
```

Publish the core first when an adapter needs a new core version.
