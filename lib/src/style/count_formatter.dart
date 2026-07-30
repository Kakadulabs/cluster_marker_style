import 'package:flutter/foundation.dart';

/// Turns a raw cluster count into the short label drawn on the icon.
///
/// Implement this to fully customize labels. Most apps use
/// [DefaultCountFormatter].
abstract class CountFormatter {
  const CountFormatter();

  /// Returns the label for [count] (always `>= 1`).
  String format(int count);
}

/// The default, good-looking formatter.
///
/// Examples:
/// ```
/// 1       -> "1"
/// 999     -> "999"
/// 1000    -> "1k"
/// 1500    -> "1.5k"
/// 12000   -> "12k"
/// 250000  -> "250k"
/// 1000000 -> "1M"
/// ```
///
/// Pass [cap] to clamp large clusters to a "N+" badge (e.g. `cap: 99` renders
/// any count above 99 as `"99+"`).
@immutable
class DefaultCountFormatter extends CountFormatter {
  const DefaultCountFormatter({this.cap})
      : assert(cap == null || cap > 0, 'cap must be positive');

  /// When non-null, counts greater than [cap] render as `"$cap+"`.
  final int? cap;

  @override
  String format(int count) {
    if (cap != null && count > cap!) return '$cap+';
    return _compact(count);
  }

  static const List<String> _suffixes = ['', 'k', 'M', 'B', 'T'];

  static String _compact(int n) {
    if (n < 1000) return '$n';

    var value = n.toDouble();
    var idx = 0;
    while (value >= 1000 && idx < _suffixes.length - 1) {
      value /= 1000;
      idx++;
    }
    // value is now in [1, 1000).

    if (value < 10) {
      // One decimal of precision for small magnitudes (e.g. "1.5k").
      final rounded = (value * 10).round() / 10;
      return '${_trimZero(rounded.toStringAsFixed(1))}${_suffixes[idx]}';
    }

    // Integer precision for larger magnitudes (e.g. "12k", "250k").
    final rounded = value.round();
    // Rounding can push e.g. 999_999 to "1000k"; promote to the next unit.
    if (rounded >= 1000 && idx < _suffixes.length - 1) {
      return '1${_suffixes[idx + 1]}';
    }
    return '$rounded${_suffixes[idx]}';
  }

  static String _trimZero(String s) =>
      s.endsWith('.0') ? s.substring(0, s.length - 2) : s;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DefaultCountFormatter && other.cap == cap;

  @override
  int get hashCode => cap.hashCode;
}
