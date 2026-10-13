/// The geometric shape used to draw a cluster icon.
///
/// v1 ships [circle]. The enum exists so that `pill` and `badge` shapes can be
/// added in a later version without an API break.
enum ClusterShape {
  /// A filled circle sized to fit the count label. The default — and the only
  /// fully supported shape in v1.
  circle,
}
