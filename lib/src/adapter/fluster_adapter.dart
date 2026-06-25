import 'dart:ui' show Offset;

import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../render/cluster_renderer.dart';

/// Builds a [Marker] for a single (non-cluster) fluster point.
typedef FlusterPointMarkerBuilder<T extends Clusterable> = Future<Marker>
    Function(T point);

/// Turns a list of fluster results into map [Marker]s, styling every cluster
/// with [renderer].
///
/// Unlike `google_maps_cluster_manager_2`, [fluster] only runs the clustering
/// *algorithm* — `Fluster.clusters(bbox, zoom)` hands back a flat list of items
/// where `isCluster == true` marks an aggregate (with `pointsSize` as the
/// count). It gives you no rendering at all, so you normally hand-build every
/// `BitmapDescriptor`. This helper does that for the clusters via [renderer] and
/// delegates individual points to [pointMarkerBuilder].
///
/// ```dart
/// final markers = await flusterMarkers(
///   items: fluster.clusters(bbox, zoom),
///   renderer: clusterRenderer,
///   devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
///   pointMarkerBuilder: (p) async => Marker(
///     markerId: MarkerId(p.markerId!),
///     position: LatLng(p.latitude!, p.longitude!),
///   ),
/// );
/// ```
Future<List<Marker>> flusterMarkers<T extends Clusterable>({
  required List<T> items,
  required ClusterRenderer renderer,
  required double devicePixelRatio,
  required FlusterPointMarkerBuilder<T> pointMarkerBuilder,
  void Function(T cluster)? onClusterTap,
}) async {
  final markers = <Marker>[];
  for (final item in items) {
    if (item.isCluster ?? false) {
      final icon = await renderer.bitmapFor(
        count: item.pointsSize ?? 0,
        devicePixelRatio: devicePixelRatio,
      );
      markers.add(
        Marker(
          markerId: MarkerId(_clusterId(item)),
          position: LatLng(item.latitude ?? 0, item.longitude ?? 0),
          icon: icon,
          // Center the bubble on the cluster location (markers default to a
          // bottom-anchored pin).
          anchor: const Offset(0.5, 0.5),
          onTap: onClusterTap == null ? null : () => onClusterTap(item),
        ),
      );
    } else {
      markers.add(await pointMarkerBuilder(item));
    }
  }
  return markers;
}

/// Convenience wrapper: query [fluster] for [bounds] at [zoom] and build the
/// markers in one call.
///
/// [bounds] is `[westLng, southLat, eastLng, northLat]` (fluster's bbox order).
Future<List<Marker>> flusterClusterMarkers<T extends Clusterable>({
  required Fluster<T> fluster,
  required List<double> bounds,
  required int zoom,
  required ClusterRenderer renderer,
  required double devicePixelRatio,
  required FlusterPointMarkerBuilder<T> pointMarkerBuilder,
  void Function(T cluster)? onClusterTap,
}) {
  return flusterMarkers<T>(
    items: fluster.clusters(bounds, zoom),
    renderer: renderer,
    devicePixelRatio: devicePixelRatio,
    pointMarkerBuilder: pointMarkerBuilder,
    onClusterTap: onClusterTap,
  );
}

String _clusterId(Clusterable item) =>
    item.markerId ??
    'cluster_${item.clusterId ?? '${item.latitude},${item.longitude}'}';
