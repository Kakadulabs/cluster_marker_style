import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Typography for the count label.
///
/// The font size is not fixed: the renderer fits the label within the padded
/// shape, clamped between [minFontSize] and [maxFontSize]. This keeps short
/// labels ("8") bold and large while long labels ("12.5k") still fit.
@immutable
class ClusterTextStyle {
  const ClusterTextStyle({
    this.color = const Color(0xFFFFFFFF),
    this.fontFamily,
    this.fontWeight = FontWeight.w600,
    this.minFontSize = 10.0,
    this.maxFontSize = 22.0,
    this.letterSpacing = 0.0,
  });

  /// Default text color. A tier's [CountTier.textColor] overrides this.
  final Color color;

  /// Optional font family. Null uses the platform default.
  final String? fontFamily;

  /// Font weight. Semibold by default for legibility at small sizes.
  final FontWeight fontWeight;

  /// Lower bound for the fitted font size (logical px).
  final double minFontSize;

  /// Upper bound for the fitted font size (logical px).
  final double maxFontSize;

  /// Letter spacing (logical px).
  final double letterSpacing;

  ClusterTextStyle copyWith({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
    double? minFontSize,
    double? maxFontSize,
    double? letterSpacing,
  }) {
    return ClusterTextStyle(
      color: color ?? this.color,
      fontFamily: fontFamily ?? this.fontFamily,
      fontWeight: fontWeight ?? this.fontWeight,
      minFontSize: minFontSize ?? this.minFontSize,
      maxFontSize: maxFontSize ?? this.maxFontSize,
      letterSpacing: letterSpacing ?? this.letterSpacing,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClusterTextStyle &&
          other.color == color &&
          other.fontFamily == fontFamily &&
          other.fontWeight == fontWeight &&
          other.minFontSize == minFontSize &&
          other.maxFontSize == maxFontSize &&
          other.letterSpacing == letterSpacing;

  @override
  int get hashCode => Object.hash(
        color,
        fontFamily,
        fontWeight,
        minFontSize,
        maxFontSize,
        letterSpacing,
      );
}
