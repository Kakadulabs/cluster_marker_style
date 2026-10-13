import 'dart:math' as math;

import 'cluster_shape.dart';
import 'cluster_style.dart';
import 'count_tier.dart';

/// Count at which the default size curve reaches [ClusterStyle.maxDiameter].
/// Clusters larger than this are capped at the max diameter.
const double kSizeCurveReferenceCount = 1000;

/// Returns the [CountTier] that applies to [count].
///
/// Tiers are matched in order: the first tier whose [CountTier.upTo] is `>=`
/// [count] wins. A count larger than every tier falls back to the last tier.
/// Tiers are expected in ascending [CountTier.upTo] order.
CountTier tierFor(ClusterStyle style, int count) {
  for (final tier in style.tiers) {
    if (count <= tier.upTo) return tier;
  }
  return style.tiers.last;
}

/// Returns the diameter (logical px) for [count].
///
/// If the matching tier pins an explicit [CountTier.size], that wins. Otherwise
/// the diameter follows a gentle logarithmic curve from
/// [ClusterStyle.minDiameter] (small clusters) up to [ClusterStyle.maxDiameter]
/// (around [kSizeCurveReferenceCount] members and beyond).
double sizeFor(ClusterStyle style, int count) {
  final tier = tierFor(style, count);
  final pinned = tier.size;
  if (pinned != null) return pinned;
  if (count <= 1) return style.minDiameter;

  final t =
      (math.log(count) / math.log(kSizeCurveReferenceCount)).clamp(0.0, 1.0);
  return style.minDiameter + (style.maxDiameter - style.minDiameter) * t;
}

/// Returns the width (logical px) of a [ClusterShape.pill] icon that is
/// [height] tall and whose label lays out [labelWidth] wide.
///
/// The label keeps the style's horizontal padding, and at least half the
/// height of total clearance so it stays clear of the rounded ends. A pill is
/// never narrower than it is tall, so short labels stay circular.
double pillWidthFor(ClusterStyle style, double height, double labelWidth) {
  final clearance = math.max(style.padding.horizontal, height / 2);
  return math.max(height, labelWidth + clearance);
}
