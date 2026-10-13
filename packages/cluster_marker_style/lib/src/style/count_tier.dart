import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// A count-aware visual bucket.
///
/// A [CountTier] applies to a cluster when its `count` is less than or equal to
/// [upTo]. Tiers are matched in ascending order of [upTo]; a count larger than
/// every tier's [upTo] falls back to the last tier. This is how a cluster of 5
/// can look meaningfully different from a cluster of 5000 with zero tuning.
@immutable
class CountTier {
  const CountTier({
    required this.upTo,
    required this.color,
    this.textColor,
    this.borderColor,
    this.size,
  });

  /// Inclusive upper bound: this tier applies when `count <= upTo`.
  final int upTo;

  /// Fill color of the shape for clusters in this tier.
  final Color color;

  /// Optional text color override. Falls back to the style's
  /// [ClusterTextStyle.color] when null.
  final Color? textColor;

  /// Optional border color override for this tier. Falls back to the style's
  /// [ClusterBorder.color]. Lets the ring be count-aware (e.g. the outlined
  /// style's colored ring). Only drawn when the style defines a border (which
  /// supplies the stroke width).
  final Color? borderColor;

  /// Optional explicit diameter (logical px). When null, the diameter is
  /// derived from the style's size curve.
  final double? size;

  CountTier copyWith({
    int? upTo,
    Color? color,
    Color? textColor,
    Color? borderColor,
    double? size,
  }) {
    return CountTier(
      upTo: upTo ?? this.upTo,
      color: color ?? this.color,
      textColor: textColor ?? this.textColor,
      borderColor: borderColor ?? this.borderColor,
      size: size ?? this.size,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountTier &&
          other.upTo == upTo &&
          other.color == color &&
          other.textColor == textColor &&
          other.borderColor == borderColor &&
          other.size == size;

  @override
  int get hashCode => Object.hash(upTo, color, textColor, borderColor, size);
}
