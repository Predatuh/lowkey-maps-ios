import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'geo_map.dart';
import 'map_viewer.dart';
import 'map_library.dart';

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
      home: const HomeScreen(),
    );
  }
}

/// Maps stored on this device (work fully offline). The bundled sample proves the
/// georeferenced-offline rendering; downloaded library maps land here too.
final List<GeoMap> _myMaps = [
  const GeoMap(
    name: 'Sample — Pierce County Solar',
    image: AssetImage('assets/sample_site.jpg'),
    tl: LatLng(42.14155644114584, -97.71037989069603),
    tr: LatLng(42.14155644114584, -97.6192974440341),
    bl: LatLng(42.10111308259549, -97.71037989069603),
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: const [
                Text('🗺️', style: TextStyle(fontSize: 30)),
                SizedBox(width: 10),
                Text('Lowkey Maps',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // ── Map Library (online) ───────────────────────────────────
            _SectionHeader('Map Library'),
            _LibraryCard(onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MapLibraryScreen()));
            }),
            const SizedBox(height: 20),

            // ── My maps (offline, on this device) ──────────────────────
            _SectionHeader('My Maps'),
            ..._myMaps.map((m) => _MapCard(
                  map: m,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => MapViewer(map: m))),
                )),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(text,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8888AA))),
      );
}

class _MapCard extends StatelessWidget {
  final GeoMap map;
  final VoidCallback onTap;
  const _MapCard({required this.map, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF111120),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.map, color: Color(0xFFA855F7)),
        title: Text(map.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '${map.center.latitude.toStringAsFixed(4)}, ${map.center.longitude.toStringAsFixed(4)}  ·  offline',
            style: const TextStyle(color: Color(0xFF8888AA))),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFA855F7)),
        onTap: onTap,
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final VoidCallback onTap;
  const _LibraryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1330),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.cloud_download, color: Color(0xFF22D3EE)),
        title: const Text('Browse the online library',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Search & download jobsite maps near you · upload your own',
            style: TextStyle(color: Color(0xFF8888AA))),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF22D3EE)),
        onTap: onTap,
      ),
    );
  }
}
