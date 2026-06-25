/// Adapter that bridges [cluster_marker_style] to
/// `google_maps_cluster_manager_2`.
///
/// Import this library (instead of, or in addition to, the core
/// `cluster_marker_style.dart`) to get the one-line [clusterMarkerBuilder]
/// helper. This is the only library in the package that depends on
/// `google_maps_cluster_manager_2`; the core stays independent so other
/// clustering tools can be adapted later without touching it.
library;

export 'cluster_marker_style.dart';
export 'src/adapter/gmcm_adapter.dart';
