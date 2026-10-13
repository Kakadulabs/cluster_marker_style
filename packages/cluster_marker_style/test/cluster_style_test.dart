import 'package:cluster_marker_style/cluster_marker_style.dart';
import 'package:flutter/painting.dart';
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

  group('ClusterStyle.copyWith clearing optional fields', () {
    test('omitting border/shadow keeps the current values', () {
      final base = ClusterStyle.soft();
      final modified = base.copyWith(minDiameter: 40);
      expect(modified.border, base.border);
      expect(modified.shadow, base.shadow);
    });

    test('removeShadow drops the shadow', () {
      final crisp = ClusterStyle.soft().copyWith(removeShadow: true);
      expect(crisp.shadow, isNull);
      // Untouched fields survive.
      expect(crisp.border, ClusterStyle.soft().border);
    });

    test('removeBorder drops the border', () {
      final ringless = ClusterStyle.soft().copyWith(removeBorder: true);
      expect(ringless.border, isNull);
      expect(ringless.shadow, ClusterStyle.soft().shadow);
    });

    test('both can be dropped at once', () {
      final bare = ClusterStyle.outlined()
          .copyWith(removeBorder: true, removeShadow: true);
      expect(bare.border, isNull);
      expect(bare.shadow, isNull);
    });

    test('replacing still works alongside the flags', () {
      const border = ClusterBorder(color: Color(0xFF00FF00), width: 4);
      final replaced =
          ClusterStyle.soft().copyWith(border: border, removeShadow: true);
      expect(replaced.border, border);
      expect(replaced.shadow, isNull);
    });

    test('setting and removing the same field at once asserts', () {
      expect(
        () => ClusterStyle.soft().copyWith(
          shadow: const ClusterShadow(),
          removeShadow: true,
        ),
        throwsAssertionError,
      );
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
