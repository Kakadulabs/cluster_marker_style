// Generates doc/named_styles.png for the README: every named style at a range
// of counts, on light and dark map-like backgrounds, with real text.
//
// Run from the package root (needs the Roboto fonts bundled with the Flutter
// SDK, found via FLUTTER_ROOT):
//   flutter test --update-goldens tool/readme_image_test.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/support/style_gallery.dart';

const _font = 'Roboto';

Future<void> _loadRoboto() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) {
    throw StateError(
        'FLUTTER_ROOT is not set; run this through `flutter test`.');
  }
  final dir = '$root/bin/cache/artifacts/material_fonts';
  final loader = FontLoader(_font);
  for (final file in [
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf'
  ]) {
    loader.addFont(File('$dir/$file').readAsBytes().then(ByteData.sublistView));
  }
  await loader.load();
}

void main() {
  testWidgets('README style gallery', (tester) async {
    const dpr = 2.0;
    final styles = {
      for (final e in galleryStyles.entries)
        e.key: e.value.copyWith(
          textStyle: e.value.textStyle.copyWith(fontFamily: _font),
        ),
    };
    final icons = (await tester.runAsync(() async {
      await _loadRoboto();
      return renderGalleryIcons(styles, devicePixelRatio: dpr);
    }))!;

    const key = Key('readme-gallery');
    await pumpGallery(
      tester,
      IntrinsicWidth(
        key: key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StyleGallery(icons: icons, devicePixelRatio: dpr),
            StyleGallery(
              icons: icons,
              devicePixelRatio: dpr,
              background: const Color(0xFF242F3E),
              labelColor: const Color(0xFFE8EAED),
            ),
          ],
        ),
      ),
      devicePixelRatio: dpr,
      fontFamily: _font,
    );

    await expectLater(
      find.byKey(key),
      matchesGoldenFile('../doc/named_styles.png'),
    );
  });
}
