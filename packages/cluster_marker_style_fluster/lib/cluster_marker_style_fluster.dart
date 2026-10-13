/// Bridges [cluster_marker_style] to the `fluster` clustering algorithm.
///
/// Provides [flusterMarkers] / [flusterClusterMarkers] and re-exports the core
/// `cluster_marker_style` library, so this single import is all you need.
library;

export 'package:cluster_marker_style/cluster_marker_style.dart';
export 'src/fluster_adapter.dart';
