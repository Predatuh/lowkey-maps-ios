import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// A georeferenced map: an image plus the real-world coordinates of its corners.
/// GPS positions are placed on it by flutter_map's projection, so it works fully offline.
class GeoMap {
  final String name;
  final ImageProvider image;
  final LatLng tl; // top-left corner
  final LatLng tr; // top-right corner
  final LatLng bl; // bottom-left corner

  const GeoMap({
    required this.name,
    required this.image,
    required this.tl,
    required this.tr,
    required this.bl,
  });

  /// Fourth corner derived from the other three (supports rotated/parallelogram maps).
  LatLng get br => LatLng(
        bl.latitude + (tr.latitude - tl.latitude),
        bl.longitude + (tr.longitude - tl.longitude),
      );

  LatLng get center => LatLng(
        (tl.latitude + br.latitude) / 2,
        (tl.longitude + br.longitude) / 2,
      );

  LatLngBounds get bounds {
    final lats = [tl.latitude, tr.latitude, bl.latitude, br.latitude];
    final lons = [tl.longitude, tr.longitude, bl.longitude, br.longitude];
    return LatLngBounds(
      LatLng(lats.reduce((a, b) => a < b ? a : b), lons.reduce((a, b) => a < b ? a : b)),
      LatLng(lats.reduce((a, b) => a > b ? a : b), lons.reduce((a, b) => a > b ? a : b)),
    );
  }
}
