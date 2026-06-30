import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(const LowkeyMapsApp());

class LowkeyMapsApp extends StatelessWidget {
  const LowkeyMapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lowkey Maps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08080F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFA855F7),
          secondary: Color(0xFF22D3EE),
          surface: Color(0xFF111120),
        ),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _map = MapController();
  StreamSubscription<Position>? _posSub;

  LatLng? _me;
  double _heading = 0;
  bool _follow = true;
  String _status = 'Getting location…';

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
      setState(() => _status = 'Turn on Location Services');
      return;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      setState(() => _status = 'Location permission needed');
      return;
    }

    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1,
      ),
    ).listen((pos) {
      final here = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _me = here;
        if (pos.heading >= 0) _heading = pos.heading;
        _status = '';
      });
      if (_follow) _map.move(here, _map.camera.zoom);
    });
  }

  void _recenter() {
    final me = _me;
    if (me == null) return;
    setState(() => _follow = true);
    _map.move(me, 17);
  }

  @override
  Widget build(BuildContext context) {
    final me = _me;
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: me ?? const LatLng(39.8283, -98.5795), // US center until first fix
              initialZoom: me == null ? 4 : 17,
              onPointerDown: (_, __) {
                if (_follow) setState(() => _follow = false);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'app.lowkeymaps.lowkeyMaps',
                maxZoom: 19,
              ),
              if (me != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: me,
                      width: 30,
                      height: 30,
                      child: Transform.rotate(
                        angle: _heading * 3.1415926 / 180,
                        child: const _MeDot(),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Title pill
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 12,
            child: _pill('Lowkey Maps'),
          ),

          // Status / hint
          if (_status.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 56,
              left: 12,
              child: _pill(_status),
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
            child: Icon(_follow ? Icons.my_location : Icons.location_searching,
                color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xE6111120),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      );
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
