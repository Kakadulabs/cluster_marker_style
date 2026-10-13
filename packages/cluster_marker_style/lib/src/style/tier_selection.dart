import 'dart:math' as math;

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
