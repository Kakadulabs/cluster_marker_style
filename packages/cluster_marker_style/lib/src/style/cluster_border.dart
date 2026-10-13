import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// An optional ring drawn around the cluster shape.
///
/// A subtle border is the cheapest way to keep light icons legible on light
/// map styles (and vice versa).
@immutable
class ClusterBorder {
  const ClusterBorder({
    required this.color,
    this.width = 2.0,
  });

  /// Stroke color of the ring.
  final Color color;

  /// Stroke width in logical px. The ring is stroked centered on the shape's
  /// edge, so it extends `width / 2` outward.
  final double width;

  ClusterBorder copyWith({Color? color, double? width}) {
    return ClusterBorder(
      color: color ?? this.color,
      width: width ?? this.width,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClusterBorder && other.color == color && other.width == width;

  @override
  int get hashCode => Object.hash(color, width);
}
