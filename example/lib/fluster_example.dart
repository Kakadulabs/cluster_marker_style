// Run with:  flutter run -t lib/fluster_example.dart
//
// Demonstrates cluster_marker_style with the `fluster` clustering algorithm.
// fluster only computes the clusters; this package styles + caches the icons.
import 'dart:math';

import 'package:cluster_marker_style/cluster_marker_style_fluster.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(const FlusterDemoApp());

class FlusterDemoApp extends StatelessWidget {
  const FlusterDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cluster_marker_style + fluster',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const FlusterDemoPage(),
    );
  }
}

/// A point to cluster. fluster items extend [Clusterable].
class MapMarker extends Clusterable {
  MapMarker({
    super.latitude,
    super.longitude,
    super.markerId,
    super.isCluster = false,
    super.clusterId,
    super.pointsSize,
    super.childMarkerId,
  });
}

enum StyleChoice {
  soft('Soft'),
  flat('Flat'),
  outlined('Outlined');

  const StyleChoice(this.label);
  final String label;

  ClusterStyle build() => switch (this) {
        StyleChoice.soft => ClusterStyle.soft(),
        StyleChoice.flat => ClusterStyle.flat(),
        StyleChoice.outlined => ClusterStyle.outlined(),
      };
}

class FlusterDemoPage extends StatefulWidget {
  const FlusterDemoPage({super.key});

  @override
  State<FlusterDemoPage> createState() => _FlusterDemoPageState();
}

class _FlusterDemoPageState extends State<FlusterDemoPage> {
  static const _center = LatLng(37.7749, -122.4194); // San Francisco

  late final Fluster<MapMarker> _fluster = _buildFluster(_generatePoints(3000));

  GoogleMapController? _controller;
  Set<Marker> _markers = <Marker>{};
  double _zoom = 10;
  double _devicePixelRatio = 2;

  StyleChoice _choice = StyleChoice.soft;
  late ClusterRenderer _renderer = ClusterRenderer(_choice.build());

  static Fluster<MapMarker> _buildFluster(List<MapMarker> points) {
    return Fluster<MapMarker>(
      minZoom: 0,
      maxZoom: 21,
      radius: 150,
      extent: 2048,
      nodeSize: 64,
      points: points,
      createCluster: (cluster, lng, lat) => MapMarker(
        latitude: lat ?? 0,
        longitude: lng ?? 0,
        isCluster: true,
        clusterId: cluster?.id,
        pointsSize: cluster?.pointsSize,
        childMarkerId: cluster?.childMarkerId,
      ),
    );
  }

  static List<MapMarker> _generatePoints(int count) {
    final rng = Random(7);
    return List<MapMarker>.generate(count, (i) {
      final lat = _center.latitude + (rng.nextDouble() - 0.5) * 0.7;
      final lng = _center.longitude + (rng.nextDouble() - 0.5) * 0.7;
      return MapMarker(latitude: lat, longitude: lng, markerId: 'p$i');
    });
  }

  Future<void> _updateClusters() async {
    final controller = _controller;
    if (controller == null) return;

    final region = await controller.getVisibleRegion();
    final bounds = <double>[
      region.southwest.longitude,
      region.southwest.latitude,
      region.northeast.longitude,
      region.northeast.latitude,
    ];
    // Before the first layout the region can be empty; skip it.
    if (bounds[0] == bounds[2] && bounds[1] == bounds[3]) return;

    // One line styles + caches every cluster icon; points use the builder.
    final markers = await flusterClusterMarkers<MapMarker>(
      fluster: _fluster,
      bounds: bounds,
      zoom: _zoom.round(),
      renderer: _renderer,
      devicePixelRatio: _devicePixelRatio,
      pointMarkerBuilder: (point) async => Marker(
        markerId: MarkerId(point.markerId ?? '${point.latitude}'),
        position: LatLng(point.latitude ?? 0, point.longitude ?? 0),
      ),
      onClusterTap: (c) => debugPrint('Tapped a cluster of ${c.pointsSize}'),
    );

    if (mounted) setState(() => _markers = markers.toSet());
  }

  void _switchStyle(StyleChoice choice) {
    setState(() {
      _choice = choice;
      _renderer = ClusterRenderer(choice.build()); // fresh, empty cache
    });
    _updateClusters();
  }

  @override
  Widget build(BuildContext context) {
    _devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                const CameraPosition(target: _center, zoom: 10),
            markers: _markers,
            onMapCreated: (controller) {
              _controller = controller;
              _updateClusters();
            },
            onCameraMove: (position) => _zoom = position.zoom,
            onCameraIdle: _updateClusters,
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SegmentedButton<StyleChoice>(
                  segments: [
                    for (final choice in StyleChoice.values)
                      ButtonSegment<StyleChoice>(
                        value: choice,
                        label: Text(choice.label),
                      ),
                  ],
                  selected: {_choice},
                  onSelectionChanged: (selection) =>
                      _switchStyle(selection.first),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
