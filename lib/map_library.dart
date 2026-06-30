import 'package:flutter/material.dart';

/// Online map library — search & download georeferenced jobsite maps (and upload your
/// own). The catalog + file hosting backend is wired in the next step; this screen is
/// the entry point and layout it plugs into.
class MapLibraryScreen extends StatefulWidget {
  const MapLibraryScreen({super.key});

  @override
  State<MapLibraryScreen> createState() => _MapLibraryScreenState();
}

class _MapLibraryScreenState extends State<MapLibraryScreen> {
  bool _sortByNearest = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Library'), backgroundColor: const Color(0xFF111120)),
      body: Column(
        children: [
          // Search + sort controls
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search maps by name…',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFF111120),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Nearest to me'),
                      selected: _sortByNearest,
                      onSelected: (_) => setState(() => _sortByNearest = true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Name'),
                      selected: !_sortByNearest,
                      onSelected: (_) => setState(() => _sortByNearest = false),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_sync, size: 56, color: Color(0xFF22D3EE)),
                    SizedBox(height: 12),
                    Text('Online library connecting…',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      'Soon you’ll search shared jobsite maps near you, download them for '
                      'offline use, and upload your own to share with the crew.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF8888AA)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFA855F7),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Map upload is being set up — coming next.')));
        },
        icon: const Icon(Icons.upload),
        label: const Text('Upload a map'),
      ),
    );
  }
}
