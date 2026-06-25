/// Adapter that bridges [cluster_marker_style] to the `fluster` clustering
/// algorithm.
///
/// Import this library (instead of, or in addition to, the core
/// `cluster_marker_style.dart`) to get [flusterMarkers] / [flusterClusterMarkers].
/// This is the only library in the package that depends on `fluster`; the core
/// stays independent so other clustering tools can be adapted without touching
/// it.
library;

export 'cluster_marker_style.dart';
export 'src/adapter/fluster_adapter.dart';
