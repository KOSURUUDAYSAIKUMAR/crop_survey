import 'dart:math' as math;
import 'package:crop_survey/model/district_feature_model.dart';
import 'package:crop_survey/utility/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DistrictGeoJsonLayer extends StatefulWidget {
  final DistrictFeatureResponse geojson;
  final Function(DistrictFeatureModel)? onFeatureTap;

  const DistrictGeoJsonLayer({
    super.key,
    required this.geojson,
    required this.onFeatureTap,
  });

  @override
  State<DistrictGeoJsonLayer> createState() => _DistrictGeoJsonLayerState();
}

class _DistrictGeoJsonLayerState extends State<DistrictGeoJsonLayer> {
  final hitNotifier = ValueNotifier<LayerHitResult<DistrictFeatureModel>?>(
    null,
  );

  @override
  void initState() {
    super.initState();
    hitNotifier.addListener(_handlePolygonTap);
  }

  @override
  void dispose() {
    hitNotifier.removeListener(_handlePolygonTap);
    hitNotifier.dispose();
    super.dispose();
  }

  void _handlePolygonTap() {
    final hit = hitNotifier.value;
    if (hit != null && widget.onFeatureTap != null) {
      final feature = hit.hitValues;
      debugPrint("---- ${feature.first}");
      debugPrint("----  ===== ${feature.last}");
      widget.onFeatureTap!(feature.single);
    }
  }

  @override
  Widget build(BuildContext context) {
    final polygons = <Polygon<DistrictFeatureModel>>[];
    final polylines = <Polyline>[];
    final markers = <Marker>[];

    for (var feature in widget.geojson.features) {
      _processFeature(feature, polygons, polylines, markers);
    }

    return Stack(
      children: [
        PolygonLayer(
          polygons: polygons,
          //  polygonCulling: false,
          hitNotifier: hitNotifier,
        ),
        PolylineLayer(polylines: polylines),
        MarkerLayer(markers: markers),
      ],
    );
  }

  void _processFeature(
    DistrictFeatureModel feature,
    List<Polygon<DistrictFeatureModel>> polygons,
    List<Polyline> polylines,
    List<Marker> markers,
  ) {
    try {
      if (feature.geometry.type == 'MultiPolygon' ||
          feature.geometry.type == 'Polygon') {
        for (var polygon in feature.geometry.coordinates) {
          for (var ring in polygon) {
            final points =
                ring.map((coord) => LatLng(coord[1], coord[0])).toList();

            if (points.length > 2) {
              polygons.add(
                Polygon<DistrictFeatureModel>(
                  points: points,
                  color: CustomColors.blueWithOpacity(0.3),
                  borderColor: Colors.blue,
                  borderStrokeWidth: 2,
                  hitValue: feature,
                ),
              );

              polylines.add(
                Polyline(points: points, color: Colors.blue, strokeWidth: 2),
              );
            }
          }
        }

        if (feature.properties.distName.isNotEmpty) {
          final centroid = _calculateCentroid(
            feature.geometry.coordinates
                .expand((polygon) => polygon.expand((ring) => ring))
                .map((coord) => LatLng(coord[1], coord[0]))
                .toList(),
          );
          markers.add(
            _buildDistrictMarker(
              centroid,
              feature.properties.distName,
              onTap: () => widget.onFeatureTap?.call(feature),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error processing feature ${feature.id}: $e');
    }
  }

  LatLng _calculateCentroid(List<LatLng> points) {
    if (points.isEmpty) return LatLng(0, 0);

    double x = 0, y = 0, z = 0;
    for (var point in points) {
      final lat = point.latitude * math.pi / 180;
      final lon = point.longitude * math.pi / 180;
      x += math.cos(lat) * math.cos(lon);
      y += math.cos(lat) * math.sin(lon);
      z += math.sin(lat);
    }

    x /= points.length;
    y /= points.length;
    z /= points.length;

    return LatLng(
      math.atan2(z, math.sqrt(x * x + y * y)) * 180 / math.pi,
      math.atan2(y, x) * 180 / math.pi,
    );
  }

  Marker _buildDistrictMarker(
    LatLng point,
    String name, {
    required VoidCallback? onTap,
  }) {
    return Marker(
      point: point,
      width: 120,
      height: 40,
      child: GestureDetector(
        onTap: () {
          onTap;
        },
        child: Text(
          name,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      /*   child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          name,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ), */
    );
  }
}
