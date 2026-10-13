/// Bridges [cluster_marker_style] to `google_maps_cluster_manager_2`.
///
/// Provides the one-line [clusterMarkerBuilder] helper and re-exports the core
/// `cluster_marker_style` library, so this single import is all you need.
library;

export 'package:cluster_marker_style/cluster_marker_style.dart';
export 'src/gmcm_adapter.dart';
