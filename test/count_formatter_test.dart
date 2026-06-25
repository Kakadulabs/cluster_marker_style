import 'package:cluster_marker_style/cluster_marker_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultCountFormatter', () {
    const f = DefaultCountFormatter();

    test('small numbers are unchanged', () {
      expect(f.format(1), '1');
      expect(f.format(42), '42');
      expect(f.format(999), '999');
    });

    test('thousands compact to k', () {
      expect(f.format(1000), '1k');
      expect(f.format(1500), '1.5k');
      expect(f.format(12000), '12k');
      expect(f.format(250000), '250k');
    });

    test('millions and billions compact to M and B', () {
      expect(f.format(1000000), '1M');
      expect(f.format(2500000), '2.5M');
      expect(f.format(1000000000), '1B');
    });

    test('rounding does not overflow the unit', () {
      // 999_999 must not render as "1000k".
      expect(f.format(999999), '1M');
    });

    test('cap renders an "N+" badge above the cap', () {
      const capped = DefaultCountFormatter(cap: 99);
      expect(capped.format(99), '99');
      expect(capped.format(100), '99+');
      expect(capped.format(5000), '99+');
    });

    test('value equality', () {
      expect(const DefaultCountFormatter(), const DefaultCountFormatter());
      expect(
        const DefaultCountFormatter(cap: 99) == const DefaultCountFormatter(),
        isFalse,
      );
    });
  });
}
