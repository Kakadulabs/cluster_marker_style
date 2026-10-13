import 'dart:ui' as ui;

import 'package:cluster_marker_style/cluster_marker_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Counts shown for every style: one or more per default tier, plus a label
/// long enough to exercise the shrink-to-fit path.
const List<int> galleryCounts = <int>[8, 42, 380, 2400, 125000];

/// The named styles, in the order the README describes them.
final Map<String, ClusterStyle> galleryStyles = <String, ClusterStyle>{
  'soft': ClusterStyle.soft(),
  'flat': ClusterStyle.flat(),
  'outlined': ClusterStyle.outlined(),
};

/// Renders every [styles] × [galleryCounts] icon through [ClusterRenderer] —
/// the same PNG bytes a map would receive — and decodes them for display.
///
/// Must run inside `tester.runAsync`: rasterizing and decoding are real async
/// work that the fake test clock never completes.
Future<Map<String, List<ui.Image>>> renderGalleryIcons(
  Map<String, ClusterStyle> styles, {
  required double devicePixelRatio,
}) async {
  final icons = <String, List<ui.Image>>{};
  for (final entry in styles.entries) {
    final renderer = ClusterRenderer(entry.value);
    final images = <ui.Image>[];
    for (final count in galleryCounts) {
      final descriptor = await renderer.bitmapFor(
        count: count,
        devicePixelRatio: devicePixelRatio,
      );
      final bytes = (descriptor as BytesMapBitmap).byteData;
      final codec = await ui.instantiateImageCodec(bytes);
      images.add((await codec.getNextFrame()).image);
    }
    icons[entry.key] = images;
  }
  return icons;
}

/// One row per style, each icon drawn at its intended logical size over a
/// map-like background.
class StyleGallery extends StatelessWidget {
  const StyleGallery({
    super.key,
    required this.icons,
    required this.devicePixelRatio,
    this.background = const Color(0xFFE8EAED),
    this.labelColor = const Color(0xFF3C4043),
  });

  final Map<String, List<ui.Image>> icons;
  final double devicePixelRatio;
  final Color background;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in icons.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 84,
                    child: Text(
                      '.${entry.key}',
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  for (final image in entry.value)
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: Center(
                        child: RawImage(image: image, scale: devicePixelRatio),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Pumps [gallery] alone, sized to its content, at [devicePixelRatio].
Future<void> pumpGallery(
  WidgetTester tester,
  Widget gallery, {
  required double devicePixelRatio,
  String? fontFamily,
}) async {
  tester.view.devicePixelRatio = devicePixelRatio;
  tester.view.physicalSize = const Size(1600, 1200) * devicePixelRatio;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: DefaultTextStyle(
        style: TextStyle(fontFamily: fontFamily),
        child: Align(
          alignment: Alignment.topLeft,
          child: RepaintBoundary(child: gallery),
        ),
      ),
    ),
  );
}
