import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
// google_maps_flutter also exports a `Cluster` type (native clustering); hide
// it so `Cluster` unambiguously means the cluster-manager's cluster.
import 'package:google_maps_flutter/google_maps_flutter.dart' hide Cluster;

import '../render/cluster_renderer.dart';

/// A function with the signature `google_maps_cluster_manager_2` expects for its
/// `markerBuilder`.
typedef ClusterMarkerBuilder<T extends ClusterItem> = Future<Marker> Function(
  Cluster<T> cluster,
);

/// Builds a `markerBuilder` for `google_maps_cluster_manager_2` that styles
/// every cluster with [renderer] — turning ~40 lines of hand-rolled canvas code
/// into one line.
///
/// ```dart
/// ClusterManager<Place>(
///   places,
///   _updateMarkers,
///   markerBuilder: clusterMarkerBuilder(
///     renderer: clusterRenderer,
///     devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
///   ),
/// );
/// ```
///
/// - Multi-item clusters are drawn by [renderer].
/// - Single-item clusters use [singleItemBuilder] when provided, otherwise they
///   fall back to a minimal styled icon from [renderer] (a "1" bubble).
/// - [onTap] is forwarded to every produced [Marker].
ClusterMarkerBuilder<T> clusterMarkerBuilder<T extends ClusterItem>({
  required ClusterRenderer renderer,
  required double devicePixelRatio,
  void Function(Cluster<T> cluster)? onTap,
  Future<Marker> Function(Cluster<T> cluster)? singleItemBuilder,
}) {
  return (Cluster<T> cluster) async {
    if (!cluster.isMultiple && singleItemBuilder != null) {
      return singleItemBuilder(cluster);
    }

    final icon = await renderer.bitmapFor(
      count: cluster.count,
      devicePixelRatio: devicePixelRatio,
    );

    return Marker(
      markerId: MarkerId(cluster.getId()),
      position: cluster.location,
      icon: icon,
      onTap: onTap == null ? null : () => onTap(cluster),
    );
  };
}
