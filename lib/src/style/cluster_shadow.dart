import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// An optional drop shadow drawn beneath the cluster shape.
///
/// Gives icons depth and keeps them legible against busy map tiles.
@immutable
class ClusterShadow {
  const ClusterShadow({
    this.color = const Color(0x33000000),
    this.blur = 6.0,
    this.offset = const Offset(0, 2),
  });

  /// Shadow color (usually translucent black).
  final Color color;

  /// Blur amount in logical px. Converted to a Gaussian sigma at paint time.
  final double blur;

  /// Shadow offset in logical px.
  final Offset offset;

  /// Maximum distance (logical px) the shadow extends beyond the shape's
  /// bounds. The renderer inflates the canvas by this amount so the shadow is
  /// never clipped.
  double get extent => blur + offset.distance;

  ClusterShadow copyWith({Color? color, double? blur, Offset? offset}) {
    return ClusterShadow(
      color: color ?? this.color,
      blur: blur ?? this.blur,
      offset: offset ?? this.offset,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClusterShadow &&
          other.color == color &&
          other.blur == blur &&
          other.offset == offset;

  @override
  int get hashCode => Object.hash(color, blur, offset);
}
