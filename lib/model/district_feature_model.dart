// class DistrictFeatureModel {
//   final String type;
//   final String id;
//   final Map<String, dynamic> properties;
//   final Map<String, dynamic> geometry;

//   DistrictFeatureModel({
//     required this.type,
//     required this.id,
//     required this.properties,
//     required this.geometry,
//   });

//   factory DistrictFeatureModel.fromJson(Map<String, dynamic> json) {
//     return DistrictFeatureModel(
//       type: json['type'],
//       id: json['id'],
//       properties: json['properties'] ?? {},
//       geometry: json['geometry'],
//     );
//   }
// }

class DistrictFeatureResponse {
  final String type;
  final List<DistrictFeatureModel> features;

  DistrictFeatureResponse({required this.type, required this.features});

  factory DistrictFeatureResponse.fromJson(Map<String, dynamic> json) {
    return DistrictFeatureResponse(
      type: json['type'],
      features: List<DistrictFeatureModel>.from(
        json['features'].map((x) => DistrictFeatureModel.fromJson(x)),
      ),
    );
  }
}

class DistrictFeatureModel {
  final String type;
  final String id;
  final DistrictGeometry geometry;
  final String geometryName;
  final DistrictProperties properties;

  DistrictFeatureModel({
    required this.type,
    required this.id,
    required this.geometry,
    required this.geometryName,
    required this.properties,
  });

  factory DistrictFeatureModel.fromJson(Map<String, dynamic> json) {
    return DistrictFeatureModel(
      type: json['type'],
      id: json['id'],
      geometry: DistrictGeometry.fromJson(json['geometry']),
      geometryName: json['geometry_name'],
      properties: DistrictProperties.fromJson(json['properties']),
    );
  }
}

class DistrictGeometry {
  final String type;
  final List<List<List<List<double>>>> coordinates;

  DistrictGeometry({required this.type, required this.coordinates});

  factory DistrictGeometry.fromJson(Map<String, dynamic> json) {
    return DistrictGeometry(
      type: json['type'],
      coordinates: List<List<List<List<double>>>>.from(
        json['coordinates'].map(
          (polygon) => List<List<List<double>>>.from(
            polygon.map(
              (ring) => List<List<double>>.from(
                ring.map(
                  (point) => List<double>.from(point.map((x) => x.toDouble())),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DistrictProperties {
  final String distName;
  final int districtCode;

  DistrictProperties({required this.distName, required this.districtCode});

  factory DistrictProperties.fromJson(Map<String, dynamic> json) {
    return DistrictProperties(
      distName: json['dist_name'],
      districtCode: json['district_c'],
    );
  }
}
