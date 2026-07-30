# cluster_marker_style

Beautiful, count-aware, **cached** cluster marker icons for Google Maps — a
one-line drop-in for any clustering algorithm.

This is a **styling/rendering layer, not a clustering algorithm.** You keep
using your clustering package of choice (e.g.
[`google_maps_cluster_manager_2`](https://pub.dev/packages/google_maps_cluster_manager_2));
this package supplies the cluster icon — rendered sharply, cached, and
good-looking by default.

> _GIF placeholder: clean count bubbles staying smooth while panning a dense map._
> Record it from the included [`example/`](example/) app.

## The problem

Clustering packages decide *which* markers group together, then hand you an
empty `markerBuilder` slot and walk away. To draw the cluster you end up
re-writing ~40 lines of `PictureRecorder` / `Canvas` / `TextPainter`
boilerplate — every project — with no caching (so the map janks on every camera
move), wrong device-pixel-ratio handling (blurry on high-DPI screens), and one
hardcoded color (a cluster of 5 looks identical to a cluster of 5000).

This is the still-open Flutter issue
[flutter/flutter#153092](https://github.com/flutter/flutter/issues/153092)
("Add support for custom cluster icon"). This package fills that gap.

## Before / after

<table>
<tr><th>Before — ~40 lines, no cache, hardcoded</th><th>After — one line</th></tr>
<tr><td>

```dart
markerBuilder: (cluster) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  const size = 120.0;
  final paint = Paint()..color = Colors.blue;
  canvas.drawCircle(
      const Offset(size / 2, size / 2), size / 2, paint);
  final tp = TextPainter(
    text: TextSpan(
      text: cluster.count.toString(),
      style: const TextStyle(
          fontSize: 40, color: Colors.white),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(
      canvas,
      Offset((size - tp.width) / 2,
             (size - tp.height) / 2));
  final img = await recorder
      .endRecording()
      .toImage(size.toInt(), size.toInt());
  final data =
      await img.toByteData(format: ImageByteFormat.png);
  // ...and you STILL have no caching, no DPR
  // handling, and no count-aware colors.
  return Marker(
    markerId: MarkerId(cluster.getId()),
    position: cluster.location,
    icon: BitmapDescriptor.fromBytes(
        data!.buffer.asUint8List()),
  );
},
```

</td><td>

```dart
final renderer = ClusterRenderer(ClusterStyle.soft());

// ...

markerBuilder: clusterMarkerBuilder(
  renderer: renderer,
  devicePixelRatio:
      MediaQuery.of(context).devicePixelRatio,
),
```

</td></tr>
</table>

## Why it's worth a dependency

Drawing a circle is trivial. The value is everything around it that developers
re-implement badly or skip:

- **Caching** — keyed on the *visual outcome*, not the raw count, so a cluster of
  47 and 48 share one bitmap. This is the single biggest factor in a smooth map.
- **Device-correct rendering** — rasterized at native resolution via
  `imagePixelRatio`, sharp on every screen, on Android, iOS, and web.
- **Count-aware defaults** — color and size change with the count automatically,
  with zero tuning.
- **Beautiful defaults** — clearly better out of the box than the red/blue circle
  everyone hand-writes.

## Quick start (with `google_maps_cluster_manager_2`)

Add the dependencies:

```yaml
dependencies:
  cluster_marker_style: ^0.3.0
  google_maps_flutter: ^2.9.0
  google_maps_cluster_manager_2: ^3.0.0
```

Wire it up:

```dart
import 'package:cluster_marker_style/cluster_marker_style_gmcm.dart';

// 1. Pick a style and create a renderer (reuse it — it holds the cache).
final renderer = ClusterRenderer(
  ClusterStyle.soft(
    tiers: const [
      CountTier(upTo: 10, color: Colors.blue),
      CountTier(upTo: 100, color: Colors.orange),
      CountTier(upTo: 1000, color: Colors.red),
    ],
  ),
);

// 2. Hand the one-line builder to your ClusterManager.
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

Omit `tiers` entirely to get the polished default ramp. See the runnable
[`example/`](example/) app, which clusters a few thousand points and switches
between styles live. (Add your own Google Maps API key — placeholders are in
`example/android/.../AndroidManifest.xml` and `example/web/index.html`.)

## Named styles

Three polished, zero-config looks that read on both light and dark maps:

| Style | Look |
| --- | --- |
| `ClusterStyle.soft()` | Cool→warm ramp, white text, thin translucent ring, soft shadow. |
| `ClusterStyle.flat()` | Solid Material colors, crisp, no ring or shadow. |
| `ClusterStyle.outlined()` | White fill with a bold count-aware colored ring + matching text. |

Each is fully overridable, or build a `ClusterStyle(...)` from scratch with your
own `tiers`, `ClusterTextStyle`, `ClusterBorder`, `ClusterShadow`, `padding`,
and `CountFormatter`.

## Scope (and what this is **not**)

This package **styles cluster icons. Bring your own clustering algorithm.** It is
deliberately small and does exactly one thing well.

It is **not** a clustering algorithm, **not** a map widget, **not** an animation
system, and **not** a viewport/diff manager. The core renderer depends only on
`google_maps_flutter` (for `BitmapDescriptor`) — importing
`package:cluster_marker_style/cluster_marker_style.dart` does **not** pull in any
clustering package. The `google_maps_cluster_manager_2` bridge lives in a
separate library
(`package:cluster_marker_style/cluster_marker_style_gmcm.dart`).

There's also a **`fluster` adapter**
(`package:cluster_marker_style/cluster_marker_style_fluster.dart`). fluster only
runs the clustering *algorithm* — it hands back a flat list where `isCluster`
marks an aggregate and gives you no rendering at all — so `flusterMarkers(...)`
styles + caches those aggregates and delegates individual points to your builder:

```dart
import 'package:cluster_marker_style/cluster_marker_style_fluster.dart';

final markers = await flusterClusterMarkers<MapMarker>(
  fluster: fluster,
  bounds: [westLng, southLat, eastLng, northLat],
  zoom: zoom.round(),
  renderer: clusterRenderer,
  devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
  pointMarkerBuilder: (p) async => Marker(
    markerId: MarkerId(p.markerId!),
    position: LatLng(p.latitude!, p.longitude!),
  ),
);
```

**More clustering-tool adapters are planned** (e.g. for `flutter_map` clustering
tools). Because the core is independent, new adapters are thin bridges that don't
touch it.

## API surface

Core (`cluster_marker_style.dart`): `ClusterStyle` (+ `.soft`/`.flat`/`.outlined`),
`CountTier`, `ClusterShape`, `ClusterTextStyle`, `ClusterBorder`,
`ClusterShadow`, `CountFormatter` (+ `DefaultCountFormatter`), `ClusterRenderer`,
`ClusterIconCache`, `ClusterCacheKey`, and the `tierFor` / `sizeFor` helpers.

Adapters:
- `cluster_marker_style_gmcm.dart` → `clusterMarkerBuilder(...)` for
  `google_maps_cluster_manager_2`.
- `cluster_marker_style_fluster.dart` → `flusterMarkers(...)` /
  `flusterClusterMarkers(...)` for `fluster`.

## License

MIT — see [LICENSE](LICENSE).
