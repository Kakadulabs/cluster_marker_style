@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';

import 'support/style_gallery.dart';

// Visual-regression check for the named styles. Text renders in the test font
// (solid boxes), which keeps the image stable across machines; the shapes,
// colors, rings and shadows are what this guards.
//
// Regenerate after an intentional visual change:
//   flutter test --update-goldens --tags golden
void main() {
  testWidgets('named styles render as expected', (tester) async {
    const dpr = 2.0;
    final icons = (await tester.runAsync(
      () => renderGalleryIcons(galleryStyles, devicePixelRatio: dpr),
    ))!;

    await pumpGallery(
      tester,
      StyleGallery(icons: icons, devicePixelRatio: dpr),
      devicePixelRatio: dpr,
    );

    await expectLater(
      find.byType(StyleGallery),
      matchesGoldenFile('goldens/named_styles.png'),
    );
  });
}
