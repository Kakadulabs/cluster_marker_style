/// Beautiful, count-aware, cached cluster marker icons for Google Maps.
///
/// This is the **core** library: a styling/rendering layer for map clustering.
/// It produces cached `BitmapDescriptor`s for a cluster whose count is already
/// known — it does not decide which markers group together. Bring your own
/// clustering algorithm.
///
/// This package does **not** depend on any specific clustering package. For a
/// ready-made bridge, add one of the adapter packages instead:
/// `cluster_marker_style_gmcm` (google_maps_cluster_manager_2) or
/// `cluster_marker_style_fluster` (fluster).
library;

// Style (data layer)
export 'src/style/cluster_border.dart';
export 'src/style/cluster_shadow.dart';
export 'src/style/cluster_shape.dart';
export 'src/style/cluster_style.dart';
export 'src/style/cluster_text_style.dart';
export 'src/style/count_formatter.dart';
export 'src/style/count_tier.dart';
export 'src/style/tier_selection.dart' show tierFor, sizeFor;

// Rendering
export 'src/render/cluster_renderer.dart';

// Caching
export 'src/cache/cluster_icon_cache.dart';
