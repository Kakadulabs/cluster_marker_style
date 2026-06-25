import 'dart:math';

import 'package:cluster_marker_style/cluster_marker_style_gmcm.dart';
import 'package:flutter/material.dart';
// google_maps_flutter also exports `Cluster` and `ClusterManager` (its native
// clustering); hide them so the names refer to google_maps_cluster_manager_2.
import 'package:google_maps_flutter/google_maps_flutter.dart'
    hide Cluster, ClusterManager;
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cluster_marker_style demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const ClusterDemoPage(),
    );
  }
}

/// A clustered point. Any class can be clustered by mixing in [ClusterItem]
/// and exposing a [location]; the mixin supplies the geohash.
class Place with ClusterItem {
  Place(this.latLng);

  final LatLng latLng;

  @override
  LatLng get location => latLng;
}

/// The three named styles the demo cycles through.
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

class ClusterDemoPage extends StatefulWidget {
  const ClusterDemoPage({super.key});

  @override
  State<ClusterDemoPage> createState() => _ClusterDemoPageState();
}

class _ClusterDemoPageState extends State<ClusterDemoPage> {
  static const _center = LatLng(37.7749, -122.4194); // San Francisco

  late final ClusterManager<Place> _manager;
  Set<Marker> _markers = <Marker>{};

  StyleChoice _choice = StyleChoice.soft;
  // The renderer is swapped when the style changes. clusterMarkerBuilder reads
  // it dynamically, so switching styles needs no map rebuild.
  late ClusterRenderer _renderer = ClusterRenderer(_choice.build());
  double _devicePixelRatio = 2;

  @override
  void initState() {
    super.initState();
    _manager = ClusterManager<Place>(
      _generatePlaces(3000),
      (markers) => setState(() => _markers = markers),
      markerBuilder: _buildClusterMarker,
      stopClusteringZoom: 17,
    );
  }

  // One line replaces ~40 lines of PictureRecorder/Canvas/TextPainter code.
  Future<Marker> _buildClusterMarker(Cluster<Place> cluster) {
    return clusterMarkerBuilder<Place>(
      renderer: _renderer,
      devicePixelRatio: _devicePixelRatio,
      onTap: (c) => debugPrint('Tapped a cluster of ${c.count}'),
    )(cluster);
  }

  void _switchStyle(StyleChoice choice) {
    setState(() {
      _choice = choice;
      _renderer = ClusterRenderer(choice.build()); // fresh, empty cache
    });
    _manager.updateMap(); // re-style the visible clusters
  }

  static List<Place> _generatePlaces(int count) {
    final rng = Random(7);
    return List<Place>.generate(count, (_) {
      final lat = _center.latitude + (rng.nextDouble() - 0.5) * 0.7;
      final lng = _center.longitude + (rng.nextDouble() - 0.5) * 0.7;
      return Place(LatLng(lat, lng));
    });
  }

  @override
  Widget build(BuildContext context) {
    _devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _center,
              zoom: 10,
            ),
            markers: _markers,
            onMapCreated: (controller) => _manager.setMapId(controller.mapId),
            onCameraMove: _manager.onCameraMove,
            onCameraIdle: _manager.updateMap,
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
