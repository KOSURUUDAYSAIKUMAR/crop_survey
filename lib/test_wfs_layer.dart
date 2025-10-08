import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class WFSVectorMap extends StatefulWidget {
  const WFSVectorMap({super.key});

  @override
  State<WFSVectorMap> createState() => _WFSVectorMapState();
}

class _WFSVectorMapState extends State<WFSVectorMap> {
  GeoJSONFeatureCollection? featureCollection;
  bool isLoading = true;
  Object? selectedHitValue;

  @override
  void initState() {
    super.initState();
    fetchWFSData();
  }

  Future<void> fetchWFSData() async {
    const wfsUrl =
        'https://agrex-demo.farmwiseai.com/geoserver/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=Puvi:district_boundary&outputFormat=application/json';

    try {
      final response = await http.get(Uri.parse(wfsUrl));
      if (response.statusCode == 200) {
        final geoJson = GeoJSONFeatureCollection.fromJSON(response.body);
        print("-------- $geoJson");
        setState(() {
          featureCollection = geoJson;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load WFS data');
      }
    } catch (e) {
      print('Error fetching WFS data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleTap(Object? hitValue) {
    setState(() => selectedHitValue = hitValue);
    if (hitValue != null) _showFeatureProperties(hitValue);
  }

  void _showFeatureProperties(Object hitValue) {
    final feature = hitValue as GeoJSONFeature;
    final properties = feature.properties;
    if (properties == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              properties['dist_name']?.toString() ?? 'Feature Details',
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children:
                    properties.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('${entry.key}: ${entry.value}'),
                      );
                    }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WFS Vector Map')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: const LatLng(10.0, 70.0),
                      initialZoom: 10.0,
                      onTap: (_, __) => _handleTap(null),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                        userAgentPackageName: "com.fai.crop_survey",
                      ),
                      if (featureCollection != null)
                        GeoJsonLayer(
                          features:
                              featureCollection!.features
                                  .where((feature) => feature != null)
                                  .cast<GeoJSONFeature>()
                                  .toList(),
                          selectedHitValue: selectedHitValue,
                          onTap: _handleTap,
                        ),
                    ],
                  ),
                  if (selectedHitValue != null)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: _buildSelectionCard(selectedHitValue!),
                    ),
                ],
              ),
    );
  }

  Widget _buildSelectionCard(Object hitValue) {
    final feature = hitValue as GeoJSONFeature;
    final properties = feature.properties ?? {};
    print('card selection name ${properties['dist_name']}');
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              properties['dist_name']?.toString() ?? 'Selected Feature',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (properties['district_c'] != null)
              Text(
                'District Code: ${properties['district_c']}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}

class GeoJsonLayer extends StatelessWidget {
  final List<GeoJSONFeature> features;
  final Object? selectedHitValue;
  final Function(Object?) onTap;

  const GeoJsonLayer({
    super.key,
    required this.features,
    required this.onTap,
    this.selectedHitValue,
  });

  @override
  Widget build(BuildContext context) {
    final polygons = <Polygon>[];
    final markers = <Marker>[];

    for (final feature in features) {
      final geometry = feature.geometry;
      if (geometry == null) continue;

      switch (geometry.type) {
        case GeoJSONType.polygon:
          _addPolygon(feature, geometry as GeoJSONPolygon, polygons);
          break;
        case GeoJSONType.multiPolygon:
          // _addMultiPolygon(feature, geometry as GeoJSONMultiPolygon, polygons);
          _addMultiPolygon(
            feature,
            geometry as GeoJSONMultiPolygon,
            polygons,
            markers,
          ); // Pass markers list
          break;
        case GeoJSONType.point:
          _addPoint(feature, geometry as GeoJSONPoint, markers);
          break;
        default:
          break;
      }
    }

    return Stack(
      children: [
        PolygonLayer(polygons: polygons),
        MarkerLayer(markers: markers),
      ],
    );
  }

  void _addPolygon(
    GeoJSONFeature feature,
    GeoJSONPolygon polygon,
    List<Polygon> polygons,
  ) {
    if (polygon.coordinates.isNotEmpty && polygon.coordinates[0].isNotEmpty) {
      final points =
          polygon.coordinates[0]
              .map((coord) => LatLng(coord[1], coord[0]))
              .toList();

      final isSelected = feature == selectedHitValue;

      polygons.add(
        Polygon(
          points: points,
          hitValue: feature,
          color:
              isSelected
                  ? Colors.blue.withOpacity(0.6)
                  : Colors.blue.withOpacity(0.3),
          borderColor: isSelected ? Colors.blueAccent : Colors.blue,
          borderStrokeWidth: isSelected ? 3 : 2,
          label: feature.properties?['dist_name']?.toString(),
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
    }
  }

  void _addMultiPolygon(
    GeoJSONFeature feature,
    GeoJSONMultiPolygon multiPolygon,
    List<Polygon> polygons,
    List<Marker> markers,
  ) {
    for (final polygonCoords in multiPolygon.coordinates) {
      if (polygonCoords.isNotEmpty && polygonCoords[0].isNotEmpty) {
        final points =
            polygonCoords[0]
                .map((coord) => LatLng(coord[1], coord[0]))
                .toList();

        final isSelected = feature == selectedHitValue;

        polygons.add(
          Polygon(
            points: points,
            hitValue: feature,
            color:
                isSelected
                    ? Colors.blue.withOpacity(0.6)
                    : Colors.blue.withOpacity(0.3),
            borderColor: isSelected ? Colors.blueAccent : Colors.blue,
            borderStrokeWidth: isSelected ? 3 : 2,
          ),
        );

        // Add a marker at the centroid of the first polygon.
        if (polygonCoords.isNotEmpty && polygonCoords[0].isNotEmpty) {
          final centroid = _calculateCentroid(
            polygonCoords[0]
                .map((coord) => LatLng(coord[1], coord[0]))
                .toList(),
          );
          if (centroid != null) {
            markers.add(_buildLabelMarker(feature, centroid));
            // _addLabelMarker(feature, centroid);
          }
        }
      }
    }
  }

  LatLng? _calculateCentroid(List<LatLng> points) {
    if (points.isEmpty) return null;

    double x = 0, y = 0;
    for (final point in points) {
      x += point.latitude;
      y += point.longitude;
    }
    return LatLng(x / points.length, y / points.length);
  }

  void _addLabelMarker(GeoJSONFeature feature, LatLng position) {
    final distName = feature.properties?['dist_name']?.toString();
    print('dist name $distName');
    if (distName != null && distName.isNotEmpty) {
      MarkerLayer(
        markers: [
          Marker(
            width: 120,
            height: 50,
            point: position,
            child: Center(
              child: Text(
                distName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Marker _buildLabelMarker(GeoJSONFeature feature, LatLng position) {
    final distName = feature.properties?['dist_name']?.toString();
    if (distName != null && distName.isNotEmpty) {
      return Marker(
        width: 120,
        height: 50,
        point: position,
        child: Center(
          child: Text(
            distName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      );
    }
    return Marker(
      point: position,
      child: Center(
        child: Text(
          "No District",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    ); //return empty marker if district name is null or empty.
  }

  void _addPoint(
    GeoJSONFeature feature,
    GeoJSONPoint point,
    List<Marker> markers,
  ) {
    if (point.coordinates.length >= 2) {
      final position = LatLng(point.coordinates[1], point.coordinates[0]);
      final isSelected = feature == selectedHitValue;
      final distName = feature.properties?['dist_name']?.toString();

      markers.add(
        Marker(
          width: isSelected ? 50 : 40,
          height: isSelected ? 50 : 40,
          point: position,
          child: GestureDetector(
            onTap: () => onTap(feature),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  color: isSelected ? Colors.redAccent : Colors.red,
                  size: isSelected ? 30 : 24,
                ),
                if (distName != null && distName.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      distName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
