import 'package:cluster_marker_style/cluster_marker_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClusterStyle value equality', () {
    test('two identical named styles are equal and share a hash', () {
      expect(ClusterStyle.soft(), ClusterStyle.soft());
      expect(ClusterStyle.soft().hashCode, ClusterStyle.soft().hashCode);
    });

    test('different named styles are not equal', () {
      expect(ClusterStyle.soft() == ClusterStyle.flat(), isFalse);
    });

    test('copyWith changes only the given field', () {
      final base = ClusterStyle.flat();
      final modified = base.copyWith(minDiameter: 99);
      expect(modified.minDiameter, 99);
      expect(modified.maxDiameter, base.maxDiameter);
      expect(modified == base, isFalse);
    });
  });

  group('named default styles', () {
    test('each ships a 3+ step tier ramp', () {
      expect(ClusterStyle.soft().tiers.length, greaterThanOrEqualTo(3));
      expect(ClusterStyle.flat().tiers.length, greaterThanOrEqualTo(3));
      expect(ClusterStyle.outlined().tiers.length, greaterThanOrEqualTo(3));
    });

    test('outlined tiers carry per-tier border colors', () {
      expect(
        ClusterStyle.outlined().tiers.every((t) => t.borderColor != null),
        isTrue,
      );
    });

    test('soft and outlined define a shadow; flat is crisp', () {
      expect(ClusterStyle.soft().shadow, isNotNull);
      expect(ClusterStyle.outlined().shadow, isNotNull);
      expect(ClusterStyle.flat().shadow, isNull);
      expect(ClusterStyle.flat().border, isNull);
    });
  });
}
