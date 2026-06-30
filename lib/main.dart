import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'geo_map.dart';
import 'map_store.dart';
import 'map_viewer.dart';

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

/// Bundled sample (proves offline georeferenced rendering).
final GeoMap _sample = GeoMap(
  name: 'Sample — Pierce County Solar',
  image: const ResizeImage(AssetImage('assets/sample_site.jpg'), width: 2400),
  tl: const LatLng(42.14155644114584, -97.71037989069603),
  tr: const LatLng(42.14155644114584, -97.6192974440341),
  bl: const LatLng(42.10111308259549, -97.71037989069603),
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<StoredMap> _stored = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final maps = await MapStore.load();
    if (mounted) setState(() => _stored = maps);
  }

  void _open(GeoMap m) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => MapViewer(map: m)));

  Future<void> _importMap() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
    );
    final path = res?.files.single.path;
    if (path == null) return;

    final geo = path.toLowerCase().endsWith('.png') ? readPngGeo(path) : null;
    final defaultName =
        res!.files.single.name.replaceAll(RegExp(r'\.(png|jpg|jpeg)$', caseSensitive: false), '');
    if (!mounted) return;

    final entry = await showDialog<StoredMap>(
      context: context,
      builder: (_) => _ImportDialog(sourcePath: path, defaultName: defaultName, geo: geo),
    );
    if (entry != null) {
      await _refresh();
      if (mounted) _open(entry.toGeoMap());
    }
  }

  Future<void> _deleteStored(StoredMap m) async {
    await MapStore.delete(m);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: const [
              Text('🗺️', style: TextStyle(fontSize: 30)),
              SizedBox(width: 10),
              Text('Lowkey Maps',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 20),
            const Text('My Maps',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8888AA))),
            const SizedBox(height: 8),

            _MapCard(
              title: _sample.name,
              subtitle:
                  '${_sample.center.latitude.toStringAsFixed(4)}, ${_sample.center.longitude.toStringAsFixed(4)}  ·  offline',
              onTap: () => _open(_sample),
            ),
            ..._stored.map((m) {
              final g = m.toGeoMap();
              return _MapCard(
                title: m.name,
                subtitle:
                    '${g.center.latitude.toStringAsFixed(4)}, ${g.center.longitude.toStringAsFixed(4)}  ·  offline',
                onTap: () => _open(g),
                onDelete: () => _deleteStored(m),
              );
            }),

            const SizedBox(height: 24),
            Text('Import a georeferenced jobsite map (PNG/JPG). For GPS to line up, the '
                'map needs its corner coordinates — auto-detected from PNG geo tags, or enter them.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFA855F7),
        onPressed: _importMap,
        icon: const Icon(Icons.add),
        label: const Text('Import map'),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  const _MapCard(
      {required this.title, required this.subtitle, required this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF111120),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.map, color: Color(0xFFA855F7)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF8888AA))),
        trailing: onDelete == null
            ? const Icon(Icons.chevron_right, color: Color(0xFFA855F7))
            : IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFF8888AA)),
                onPressed: onDelete,
              ),
        onTap: onTap,
      ),
    );
  }
}

/// Collects name + corner coordinates for an imported map (prefilled from PNG geo if found).
class _ImportDialog extends StatefulWidget {
  final String sourcePath;
  final String defaultName;
  final Map<String, double>? geo;
  const _ImportDialog({required this.sourcePath, required this.defaultName, this.geo});

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  late final _name = TextEditingController(text: widget.defaultName);
  late final _tlLat = TextEditingController(text: _g('geo_tl_lat'));
  late final _tlLon = TextEditingController(text: _g('geo_tl_lon'));
  late final _trLat = TextEditingController(text: _g('geo_tr_lat'));
  late final _trLon = TextEditingController(text: _g('geo_tr_lon'));
  late final _blLat = TextEditingController(text: _g('geo_bl_lat'));
  late final _blLon = TextEditingController(text: _g('geo_bl_lon'));
  String? _error;

  String _g(String k) => widget.geo?[k]?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111120),
      title: const Text('Import map'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.geo != null)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Corner coordinates auto-detected from the PNG.',
                    style: TextStyle(color: Color(0xFF22D3EE), fontSize: 12)),
              ),
            _field(_name, 'Map name'),
            const SizedBox(height: 8),
            const Text('Top-left corner', style: TextStyle(color: Color(0xFF8888AA))),
            Row(children: [
              Expanded(child: _field(_tlLat, 'lat')),
              const SizedBox(width: 8),
              Expanded(child: _field(_tlLon, 'lon')),
            ]),
            const Text('Top-right corner', style: TextStyle(color: Color(0xFF8888AA))),
            Row(children: [
              Expanded(child: _field(_trLat, 'lat')),
              const SizedBox(width: 8),
              Expanded(child: _field(_trLon, 'lon')),
            ]),
            const Text('Bottom-left corner', style: TextStyle(color: Color(0xFF8888AA))),
            Row(children: [
              Expanded(child: _field(_blLat, 'lat')),
              const SizedBox(width: 8),
              Expanded(child: _field(_blLon, 'lon')),
            ]),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Import')),
      ],
    );
  }

  Widget _field(TextEditingController c, String hint) => TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        decoration: InputDecoration(hintText: hint, isDense: true),
      );

  Future<void> _save() async {
    final name = _name.text.trim();
    final vals = [_tlLat, _tlLon, _trLat, _trLon, _blLat, _blLon]
        .map((c) => double.tryParse(c.text.trim()))
        .toList();
    if (name.isEmpty) {
      setState(() => _error = 'Enter a name'); return;
    }
    if (vals.any((v) => v == null)) {
      setState(() => _error = 'Enter all 6 corner coordinates (decimal degrees)'); return;
    }
    final entry = await MapStore.import(
      sourcePath: widget.sourcePath,
      name: name,
      tlLat: vals[0]!, tlLon: vals[1]!,
      trLat: vals[2]!, trLon: vals[3]!,
      blLat: vals[4]!, blLon: vals[5]!,
    );
    if (mounted) Navigator.pop(context, entry);
  }
}
