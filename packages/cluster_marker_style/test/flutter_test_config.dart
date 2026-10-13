import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pixels may differ by this fraction before a golden fails. Anti-aliasing and
/// blur output vary slightly between platforms and Skia versions; a real
/// regression (wrong color, clipped shadow, moved ring) changes far more.
const double _goldenTolerance = 0.005;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  if (goldenFileComparator is LocalFileComparator) {
    final current = goldenFileComparator as LocalFileComparator;
    goldenFileComparator = _TolerantComparator(
      // basedir is a directory URI; LocalFileComparator wants a file inside it.
      current.basedir.resolve('flutter_test_config.dart'),
    );
  }
  await testMain();
}

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= _goldenTolerance) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
