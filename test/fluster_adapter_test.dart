import 'package:cluster_marker_style/cluster_marker_style_fluster.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class _Item extends Clusterable {
  _Item({
    super.latitude,
    super.longitude,
    super.isCluster,
    super.clusterId,
    super.pointsSize,
    super.markerId,
  });
}

void main() {
  testWidgets('flusterMarkers renders clusters and delegates points',
      (tester) async {
    await tester.runAsync(() async {
      final renderer = ClusterRenderer(ClusterStyle.soft());
      final items = <_Item>[
        _Item(
          latitude: 1,
          longitude: 2,
          isCluster: true,
          clusterId: 7,
          pointsSize: 25,
        ),
        _Item(latitude: 3, longitude: 4, markerId: 'p1'),
      ];

      var pointBuilds = 0;
      final markers = await flusterMarkers<_Item>(
        items: items,
        renderer: renderer,
        devicePixelRatio: 2,
        pointMarkerBuilder: (p) async {
          pointBuilds++;
          return Marker(
            markerId: MarkerId(p.markerId!),
            position: LatLng(p.latitude!, p.longitude!),
          );
        },
      );

      expect(markers.length, 2);
      // The single point went through the developer-supplied builder.
      expect(pointBuilds, 1);

      // The cluster got a rendered, center-anchored bubble at its location.
      final cluster =
          markers.firstWhere((m) => m.markerId.value == 'cluster_7');
      expect(cluster.position, const LatLng(1, 2));
      expect(cluster.anchor, const Offset(0.5, 0.5));

      // The cluster icon was rendered + cached.
      expect(renderer.cache.length, 1);
    });
  });

  testWidgets('markers come back in the order the items were given',
      (tester) async {
    await tester.runAsync(() async {
      final items = <_Item>[
        _Item(
            latitude: 0,
            longitude: 0,
            isCluster: true,
            clusterId: 1,
            pointsSize: 5),
        _Item(latitude: 1, longitude: 1, markerId: 'p1'),
        _Item(
            latitude: 2,
            longitude: 2,
            isCluster: true,
            clusterId: 2,
            pointsSize: 500),
        _Item(latitude: 3, longitude: 3, markerId: 'p2'),
      ];

      final markers = await flusterMarkers<_Item>(
        items: items,
        renderer: ClusterRenderer(ClusterStyle.soft()),
        devicePixelRatio: 2,
        pointMarkerBuilder: (p) async => Marker(
          markerId: MarkerId(p.markerId!),
          position: LatLng(p.latitude!, p.longitude!),
        ),
      );

      // Clusters render concurrently; order must still track the input.
      expect(
        markers.map((m) => m.markerId.value).toList(),
        <String>['cluster_1', 'p1', 'cluster_2', 'p2'],
      );
    });
  });

  testWidgets('a point item is not treated as a cluster', (tester) async {
    await tester.runAsync(() async {
      final renderer = ClusterRenderer(ClusterStyle.flat());
      final markers = await flusterMarkers<_Item>(
        items: <_Item>[_Item(latitude: 0, longitude: 0, markerId: 'only')],
        renderer: renderer,
        devicePixelRatio: 2,
        pointMarkerBuilder: (p) async =>
            Marker(markerId: MarkerId(p.markerId!)),
      );
      expect(markers.single.markerId.value, 'only');
      // No cluster icon was rendered.
      expect(renderer.cache.length, 0);
    });
  });
}
