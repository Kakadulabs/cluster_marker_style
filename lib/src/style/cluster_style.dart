import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'cluster_border.dart';
import 'cluster_shadow.dart';
import 'cluster_shape.dart';
import 'cluster_text_style.dart';
import 'count_formatter.dart';
import 'count_tier.dart';

/// Immutable description of how a cluster icon should look.
///
/// A [ClusterStyle] is pure configuration — it does no painting. Hand it to a
/// `ClusterRenderer` to produce cached `BitmapDescriptor`s.
///
/// Use a named constructor ([ClusterStyle.soft], [ClusterStyle.flat],
/// [ClusterStyle.outlined]) for a polished look with zero tuning, or the
/// default constructor for full control.
///
/// [ClusterStyle] implements value equality so two identical styles share cache
/// entries.
@immutable
class ClusterStyle {
  const ClusterStyle({
    this.shape = ClusterShape.circle,
    required this.tiers,
    this.textStyle = const ClusterTextStyle(),
    this.border,
    this.shadow,
    this.padding = const EdgeInsets.all(8),
    this.countFormatter = const DefaultCountFormatter(),
    this.minDiameter = 36.0,
    this.maxDiameter = 72.0,
  });
  // Note: [tiers] must contain at least one entry. It is not asserted here so
  // that `const ClusterStyle(...)` remains valid (List.length is not
  // const-evaluable); tier selection relies on a non-empty list.

  /// The shape drawn behind the count. v1 supports [ClusterShape.circle].
  final ClusterShape shape;

  /// Count-aware color/size buckets, expected in ascending [CountTier.upTo]
  /// order. Counts above the last tier fall back to it.
  final List<CountTier> tiers;

  /// Typography for the count label.
  final ClusterTextStyle textStyle;

  /// Optional ring around the shape.
  final ClusterBorder? border;

  /// Optional drop shadow.
  final ClusterShadow? shadow;

  /// Text padding inside the shape (logical px). Drives the fitted font size.
  final EdgeInsets padding;

  /// Formats the raw count into the drawn label.
  final CountFormatter countFormatter;

  /// Smallest diameter (logical px) of the size curve, used for small clusters
  /// when a tier does not pin an explicit [CountTier.size].
  final double minDiameter;

  /// Largest diameter (logical px) of the size curve, used for the biggest
  /// clusters.
  final double maxDiameter;

  // ---------------------------------------------------------------------------
  // Named constructors — polished, zero-config defaults.
  // ---------------------------------------------------------------------------

  /// Soft, modern look: a cool→warm color ramp, white semibold text, a thin
  /// translucent-white ring, and a gentle drop shadow. Reads well on both light
  /// and dark map styles.
  factory ClusterStyle.soft({
    List<CountTier>? tiers,
    CountFormatter countFormatter = const DefaultCountFormatter(),
    double minDiameter = 38.0,
    double maxDiameter = 76.0,
  }) {
    return ClusterStyle(
      shape: ClusterShape.circle,
      tiers: tiers ?? _softTiers,
      textStyle: const ClusterTextStyle(
        color: Color(0xFFFFFFFF),
        fontWeight: FontWeight.w700,
        minFontSize: 11,
        maxFontSize: 24,
        letterSpacing: 0.2,
      ),
      border: const ClusterBorder(color: Color(0xCCFFFFFF), width: 1.5),
      shadow: const ClusterShadow(
        color: Color(0x40000000),
        blur: 8,
        offset: Offset(0, 3),
      ),
      padding: const EdgeInsets.all(9),
      countFormatter: countFormatter,
      minDiameter: minDiameter,
      maxDiameter: maxDiameter,
    );
  }

  /// Flat, crisp Material look: solid color, white text, no ring, no shadow.
  factory ClusterStyle.flat({
    List<CountTier>? tiers,
    CountFormatter countFormatter = const DefaultCountFormatter(),
    double minDiameter = 36.0,
    double maxDiameter = 70.0,
  }) {
    return ClusterStyle(
      shape: ClusterShape.circle,
      tiers: tiers ?? _flatTiers,
      textStyle: const ClusterTextStyle(
        color: Color(0xFFFFFFFF),
        fontWeight: FontWeight.w600,
        minFontSize: 11,
        maxFontSize: 22,
      ),
      padding: const EdgeInsets.all(8),
      countFormatter: countFormatter,
      minDiameter: minDiameter,
      maxDiameter: maxDiameter,
    );
  }

  /// Outlined look: a white fill with a bold count-aware colored ring and
  /// matching colored text. Stays legible on busy, colorful map tiles.
  factory ClusterStyle.outlined({
    List<CountTier>? tiers,
    CountFormatter countFormatter = const DefaultCountFormatter(),
    double minDiameter = 38.0,
    double maxDiameter = 74.0,
  }) {
    return ClusterStyle(
      shape: ClusterShape.circle,
      tiers: tiers ?? _outlinedTiers,
      textStyle: const ClusterTextStyle(
        color: Color(0xFF202124),
        fontWeight: FontWeight.w700,
        minFontSize: 11,
        maxFontSize: 23,
      ),
      // Color is the per-tier fallback; each tier overrides it via borderColor.
      border: const ClusterBorder(color: Color(0xFF202124), width: 3.5),
      shadow: const ClusterShadow(
        color: Color(0x33000000),
        blur: 6,
        offset: Offset(0, 2),
      ),
      padding: const EdgeInsets.all(8),
      countFormatter: countFormatter,
      minDiameter: minDiameter,
      maxDiameter: maxDiameter,
    );
  }

  // ---------------------------------------------------------------------------
  // Default tier ramps.
  // ---------------------------------------------------------------------------

  static const List<CountTier> _softTiers = <CountTier>[
    CountTier(upTo: 20, color: Color(0xFF5B8DEF)), // azure
    CountTier(upTo: 100, color: Color(0xFF7B61FF)), // violet
    CountTier(upTo: 1000, color: Color(0xFFE66BB0)), // rose
    CountTier(upTo: 1 << 30, color: Color(0xFFF2683C)), // coral
  ];

  static const List<CountTier> _flatTiers = <CountTier>[
    CountTier(upTo: 20, color: Color(0xFF1E88E5)), // blue 600
    CountTier(upTo: 100, color: Color(0xFF00897B)), // teal 600
    CountTier(upTo: 1000, color: Color(0xFFF57C00)), // orange 700
    CountTier(upTo: 1 << 30, color: Color(0xFFE53935)), // red 600
  ];

  static const List<CountTier> _outlinedTiers = <CountTier>[
    CountTier(
      upTo: 20,
      color: Color(0xFFFFFFFF),
      borderColor: Color(0xFF2D9CDB),
      textColor: Color(0xFF1B6CA8),
    ),
    CountTier(
      upTo: 100,
      color: Color(0xFFFFFFFF),
      borderColor: Color(0xFF27AE8F),
      textColor: Color(0xFF1B7A66),
    ),
    CountTier(
      upTo: 1000,
      color: Color(0xFFFFFFFF),
      borderColor: Color(0xFFF2994A),
      textColor: Color(0xFFB76C24),
    ),
    CountTier(
      upTo: 1 << 30,
      color: Color(0xFFFFFFFF),
      borderColor: Color(0xFFEB5757),
      textColor: Color(0xFFB23939),
    ),
  ];

  ClusterStyle copyWith({
    ClusterShape? shape,
    List<CountTier>? tiers,
    ClusterTextStyle? textStyle,
    ClusterBorder? border,
    ClusterShadow? shadow,
    EdgeInsets? padding,
    CountFormatter? countFormatter,
    double? minDiameter,
    double? maxDiameter,
  }) {
    return ClusterStyle(
      shape: shape ?? this.shape,
      tiers: tiers ?? this.tiers,
      textStyle: textStyle ?? this.textStyle,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      padding: padding ?? this.padding,
      countFormatter: countFormatter ?? this.countFormatter,
      minDiameter: minDiameter ?? this.minDiameter,
      maxDiameter: maxDiameter ?? this.maxDiameter,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClusterStyle &&
          other.shape == shape &&
          listEquals(other.tiers, tiers) &&
          other.textStyle == textStyle &&
          other.border == border &&
          other.shadow == shadow &&
          other.padding == padding &&
          other.countFormatter == countFormatter &&
          other.minDiameter == minDiameter &&
          other.maxDiameter == maxDiameter;

  @override
  int get hashCode => Object.hash(
        shape,
        Object.hashAll(tiers),
        textStyle,
        border,
        shadow,
        padding,
        countFormatter,
        minDiameter,
        maxDiameter,
      );
}
