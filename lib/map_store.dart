import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

import 'geo_map.dart';

/// A georeferenced map saved on this device.
class StoredMap {
  final String name;
  final String imagePath; // absolute path to the copied image file
  final double tlLat, tlLon, trLat, trLon, blLat, blLon;

  StoredMap({
    required this.name,
    required this.imagePath,
    required this.tlLat,
    required this.tlLon,
    required this.trLat,
    required this.trLon,
    required this.blLat,
    required this.blLon,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'imagePath': imagePath,
        'tlLat': tlLat, 'tlLon': tlLon,
        'trLat': trLat, 'trLon': trLon,
        'blLat': blLat, 'blLon': blLon,
      };

  static StoredMap fromJson(Map<String, dynamic> j) => StoredMap(
        name: j['name'] as String,
        imagePath: j['imagePath'] as String,
        tlLat: (j['tlLat'] as num).toDouble(), tlLon: (j['tlLon'] as num).toDouble(),
        trLat: (j['trLat'] as num).toDouble(), trLon: (j['trLon'] as num).toDouble(),
        blLat: (j['blLat'] as num).toDouble(), blLon: (j['blLon'] as num).toDouble(),
      );

  /// Render model. Decode resolution is capped so large images don't blow past
  /// memory / GPU texture limits.
  GeoMap toGeoMap() => GeoMap(
        name: name,
        image: ResizeImage(FileImage(File(imagePath)), width: 2400),
        tl: LatLng(tlLat, tlLon),
        tr: LatLng(trLat, trLon),
        bl: LatLng(blLat, blLon),
      );
}

/// Persists the user's imported maps as a JSON catalog in the app documents dir.
class MapStore {
  static Future<Directory> _dir() async {
    final docs = await getApplicationDocumentsDirectory();
    final d = Directory('${docs.path}/maps');
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  static Future<File> _catalogFile() async =>
      File('${(await _dir()).path}/catalog.json');

  static Future<List<StoredMap>> load() async {
    try {
      final f = await _catalogFile();
      if (!await f.exists()) return [];
      final list = jsonDecode(await f.readAsString()) as List;
      return list.map((e) => StoredMap.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _save(List<StoredMap> maps) async {
    final f = await _catalogFile();
    await f.writeAsString(jsonEncode(maps.map((m) => m.toJson()).toList()));
  }

  /// Copies [sourcePath] into app storage and adds a catalog entry. Returns the entry.
  static Future<StoredMap> import({
    required String sourcePath,
    required String name,
    required double tlLat, required double tlLon,
    required double trLat, required double trLon,
    required double blLat, required double blLon,
  }) async {
    final dir = await _dir();
    final ext = sourcePath.contains('.') ? sourcePath.split('.').last : 'img';
    final dest = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await File(sourcePath).copy(dest);
    final entry = StoredMap(
      name: name, imagePath: dest,
      tlLat: tlLat, tlLon: tlLon, trLat: trLat, trLon: trLon, blLat: blLat, blLon: blLon,
    );
    final maps = await load();
    maps.add(entry);
    await _save(maps);
    return entry;
  }

  static Future<void> delete(StoredMap m) async {
    final maps = await load();
    maps.removeWhere((e) => e.imagePath == m.imagePath);
    await _save(maps);
    try { await File(m.imagePath).delete(); } catch (_) {}
  }
}

/// Best-effort: read corner coordinates embedded in a PNG's tEXt chunks
/// (keys geo_tl_lat / geo_tl_lon / geo_tr_lat / geo_tr_lon / geo_bl_lat / geo_bl_lon),
/// the same format produced by the project's map-export tooling. Returns null if absent.
Map<String, double>? readPngGeo(String path) {
  try {
    final bytes = File(path).readAsBytesSync();
    if (bytes.length < 8 || bytes[0] != 0x89 || bytes[1] != 0x50) return null; // not PNG
    final out = <String, double>{};
    var i = 8;
    while (i + 8 <= bytes.length) {
      final len = (bytes[i] << 24) | (bytes[i + 1] << 16) | (bytes[i + 2] << 8) | bytes[i + 3];
      final type = String.fromCharCodes(bytes.sublist(i + 4, i + 8));
      final dataStart = i + 8;
      if (type == 'IEND') break;
      if (type == 'tEXt' && len > 0 && dataStart + len <= bytes.length) {
        final data = bytes.sublist(dataStart, dataStart + len);
        final sep = data.indexOf(0);
        if (sep > 0) {
          final key = String.fromCharCodes(data.sublist(0, sep));
          final value = String.fromCharCodes(data.sublist(sep + 1));
          final d = double.tryParse(value);
          if (d != null) out[key] = d;
        }
      }
      i = dataStart + len + 4; // skip data + CRC
    }
    final needed = ['geo_tl_lat', 'geo_tl_lon', 'geo_tr_lat', 'geo_tr_lon', 'geo_bl_lat', 'geo_bl_lon'];
    if (needed.every(out.containsKey)) return out;
    return null;
  } catch (_) {
    return null;
  }
}
