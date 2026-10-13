/// The geometric shape used to draw a cluster icon.
enum ClusterShape {
  /// A filled circle sized to fit the count label. The default. Long labels
  /// shrink (down to `ClusterTextStyle.minFontSize`) to fit inside it.
  circle,

  /// A stadium (rounded-end rectangle) as tall as the circle would be, that
  /// widens for long labels instead of shrinking them. Short labels still
  /// render as a plain circle.
  pill,
}
