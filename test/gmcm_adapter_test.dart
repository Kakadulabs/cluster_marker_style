import 'package:cluster_marker_style/cluster_marker_style_gmcm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
// google_maps_flutter also exports a `Cluster` type (native clustering); hide
// it so `Cluster` unambiguously means the cluster-manager's cluster.
import 'package:google_maps_flutter/google_maps_flutter.dart' hide Cluster;

class _Place with ClusterItem {
  _Place(this.location);

  @override
  final LatLng location;
}

void main() {
  final places = <_Place>[
    _Place(const LatLng(1, 2)),
    _Place(const LatLng(1.1, 2.1)),
    _Place(const LatLng(1.2, 2.2)),
  ];
  final multi = Cluster<_Place>(places, const LatLng(1, 2));
  final single = Cluster<_Place>(places.take(1), const LatLng(3, 4));

  testWidgets('multi-item cluster gets a rendered, center-anchored bubble',
      (tester) async {
    await tester.runAsync(() async {
      final renderer = ClusterRenderer(ClusterStyle.soft());
      final builder = clusterMarkerBuilder<_Place>(
        renderer: renderer,
        devicePixelRatio: 2,
      );

      final marker = await builder(multi);

      expect(marker.markerId.value, multi.getId());
      expect(marker.position, const LatLng(1, 2));
      expect(marker.anchor, const Offset(0.5, 0.5));
      expect(renderer.cache.length, 1);
    });
  });

  testWidgets('singleItemBuilder takes over single-item clusters',
      (tester) async {
    await tester.runAsync(() async {
      final renderer = ClusterRenderer(ClusterStyle.soft());
      var singleBuilds = 0;
      final builder = clusterMarkerBuilder<_Place>(
        renderer: renderer,
        devicePixelRatio: 2,
        singleItemBuilder: (cluster) async {
          singleBuilds++;
          return const Marker(markerId: MarkerId('single'));
        },
      );

      final marker = await builder(single);

      expect(singleBuilds, 1);
      expect(marker.markerId.value, 'single');
      // No cluster icon was rendered.
      expect(renderer.cache.length, 0);
    });
  });

  testWidgets('without singleItemBuilder a single item still gets a bubble',
      (tester) async {
    await tester.runAsync(() async {
      final renderer = ClusterRenderer(ClusterStyle.soft());
      final builder = clusterMarkerBuilder<_Place>(
        renderer: renderer,
        devicePixelRatio: 2,
      );

      final marker = await builder(single);

      expect(marker.position, const LatLng(3, 4));
      expect(renderer.cache.length, 1);
    });
  });

  testWidgets('onTap is forwarded to the produced marker', (tester) async {
    await tester.runAsync(() async {
      Cluster<_Place>? tapped;
      final builder = clusterMarkerBuilder<_Place>(
        renderer: ClusterRenderer(ClusterStyle.flat()),
        devicePixelRatio: 2,
        onTap: (cluster) => tapped = cluster,
      );

      final marker = await builder(multi);
      expect(marker.onTap, isNotNull);
      marker.onTap!();
      expect(tapped, same(multi));
    });
  });

  testWidgets('no onTap leaves the marker callback null', (tester) async {
    await tester.runAsync(() async {
      final builder = clusterMarkerBuilder<_Place>(
        renderer: ClusterRenderer(ClusterStyle.flat()),
        devicePixelRatio: 2,
      );

      final marker = await builder(multi);
      expect(marker.onTap, isNull);
    });
  });

  testWidgets('identical counts across clusters share one cached bitmap',
      (tester) async {
    await tester.runAsync(() async {
      final renderer = ClusterRenderer(ClusterStyle.soft());
      final builder = clusterMarkerBuilder<_Place>(
        renderer: renderer,
        devicePixelRatio: 2,
      );

      await builder(multi);
      await builder(Cluster<_Place>(places, const LatLng(50, 60)));

      // Same count, same style, same dpr => one rasterization.
      expect(renderer.cache.length, 1);
    });
  });
}
