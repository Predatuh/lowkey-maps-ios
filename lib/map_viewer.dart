import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'geo_map.dart';

/// Fully-offline georeferenced map viewer: draws the map image at its real-world
/// corners and overlays the live GPS position. No network/tiles required.
class MapViewer extends StatefulWidget {
  final GeoMap map;
  const MapViewer({super.key, required this.map});

  @override
  State<MapViewer> createState() => _MapViewerState();
}

class _MapViewerState extends State<MapViewer> {
  final MapController _map = MapController();
  StreamSubscription<Position>? _posSub;
  LatLng? _me;
  double _heading = 0;
  bool _follow = false;
  String _status = '';

  static const _accent = Color(0xFFA855F7);

  @override
  void initState() {
    super.initState();
    _startLocation();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  Future<void> _startLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() => _status = 'Location off');
      return;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      setState(() => _status = 'No location permission');
      return;
    }
    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 1),
    ).listen((pos) {
      final here = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _me = here;
        if (pos.heading >= 0) _heading = pos.heading;
      });
      if (_follow) _map.move(here, _map.camera.zoom);
    });
  }

  void _recenter() {
    final me = _me;
    if (me == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No GPS fix yet')));
      return;
    }
    setState(() => _follow = true);
    _map.move(me, 18);
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.map;
    final me = _me;
    return Scaffold(
      appBar: AppBar(title: Text(m.name), backgroundColor: const Color(0xFF111120)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCameraFit: CameraFit.bounds(
                bounds: m.bounds,
                padding: const EdgeInsets.all(24),
              ),
              minZoom: 1,
              maxZoom: 22,
              backgroundColor: const Color(0xFF08080F),
              onPointerDown: (_, __) {
                if (_follow) setState(() => _follow = false);
              },
            ),
            children: [
              OverlayImageLayer(
                overlayImages: [
                  RotatedOverlayImage(
                    topLeftCorner: m.tl,
                    bottomLeftCorner: m.bl,
                    bottomRightCorner: m.br,
                    imageProvider: m.image,
                    filterQuality: FilterQuality.medium,
                  ),
                ],
              ),
              if (me != null)
                MarkerLayer(markers: [
                  Marker(
                    point: me,
                    width: 28,
                    height: 28,
                    child: Transform.rotate(
                      angle: _heading * 3.1415926 / 180,
                      child: const _MeDot(),
                    ),
                  ),
                ]),
            ],
          ),
          if (_status.isNotEmpty)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: const Color(0xE6111120), borderRadius: BorderRadius.circular(16)),
                child: Text(_status, style: const TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'zin',
            backgroundColor: const Color(0xFF1A1A28),
            onPressed: () => _map.move(_map.camera.center, _map.camera.zoom + 1),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'zout',
            backgroundColor: const Color(0xFF1A1A28),
            onPressed: () => _map.move(_map.camera.center, _map.camera.zoom - 1),
            child: const Icon(Icons.remove, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'loc',
            backgroundColor: _follow ? _accent : const Color(0xFF1A1A28),
            onPressed: _recenter,
            child: Icon(_follow ? Icons.my_location : Icons.location_searching, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _MeDot extends StatelessWidget {
  const _MeDot();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E88E5),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Color(0x551E88E5), blurRadius: 12, spreadRadius: 4)],
      ),
    );
  }
}
