import 'package:crop_wizard/core/constants/app_global.dart';
import 'package:crop_wizard/core/utils/custom_logger.dart';

class FmbResponseModel {
  final String type;
  final String name;
  final CrsModel crs;
  final List<FeatureModel> features;

  FmbResponseModel({
    required this.type,
    required this.name,
    required this.crs,
    required this.features,
  });

  factory FmbResponseModel.fromJson(Map<String, dynamic> json) {
    return FmbResponseModel(
      type: json['type'],
      name: json['name'],
      crs: CrsModel.fromJson(json['crs']),
      features: List<FeatureModel>.from(
        json['features'].map((x) => FeatureModel.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'crs': crs.toJson(),
      'features': features.map((x) => x.toJson()).toList(),
    };
  }
}

class CrsModel {
  final String type;
  final PropertiesModel properties;

  CrsModel({
    required this.type,
    required this.properties,
  });

  factory CrsModel.fromJson(Map<String, dynamic> json) {
    return CrsModel(
      type: json['type'],
      properties: PropertiesModel.fromJson(json['properties']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'properties': properties.toJson(),
    };
  }
}

class PropertiesModel {
  final String name;

  PropertiesModel({required this.name});

  factory PropertiesModel.fromJson(Map<String, dynamic> json) {
    return PropertiesModel(name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

class FeatureModel {
  final String type;
  final FeaturePropertiesModel properties;
  final GeometryModel geometry;

  FeatureModel({
    required this.type,
    required this.properties,
    required this.geometry,
  });

  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    return FeatureModel(
      type: json['type'],
      properties: FeaturePropertiesModel.fromJson(json['properties']),
      geometry: GeometryModel.fromJson(json['geometry']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'properties': properties.toJson(),
      'geometry': geometry.toJson(),
    };
  }
}

class FeaturePropertiesModel {
  final String? kide;
  final String? area;
  final String? dc;
  final String? tc;
  final String? hc;
  final String? vc;
  final String? rotation;
  final String? classType;
  final String? classCat;
  final int? landId;
  final int? surveyNumber;
  final String? subdivisionNumber;
  final String? uniqueId1;
  final String? uniqueId2;
  final int? uidReginetAvail;
  final int? uidTnAvail;
  final int? uidCsAvail;
  final String? reginetGuidelineValue;
  final int? reginetGlv;
  final String? reginetUnitType;
  final String? reginetLandClassification;
  final int? tamilnilamPattaNumber;
  final String? tamilnilamGovernmentPriority;
  final int? tamilnilamExtentAres;
  final String? tamilnilamLandType;
  final String? tamilnilamOwnerDetails;
  final String? kharifCropClassification;
  final String? kharifCropName;
  final double? kharifArea;
  final String? rabiCropClassification;
  final String? rabiCropName;
  final double? rabiArea;
  final String? baseUid;
  final String? parkName;
  final int? parkId;

  FeaturePropertiesModel({
    this.kide,
    this.area,
    this.dc,
    this.tc,
    this.hc,
    this.vc,
    this.rotation,
    this.classType,
    this.classCat,
    this.landId,
    this.surveyNumber,
    this.subdivisionNumber,
    this.uniqueId1,
    this.uniqueId2,
    this.uidReginetAvail,
    this.uidTnAvail,
    this.uidCsAvail,
    this.reginetGuidelineValue,
    this.reginetGlv,
    this.reginetUnitType,
    this.reginetLandClassification,
    this.tamilnilamPattaNumber,
    this.tamilnilamGovernmentPriority,
    this.tamilnilamExtentAres,
    this.tamilnilamLandType,
    this.tamilnilamOwnerDetails,
    this.kharifCropClassification,
    this.kharifCropName,
    this.kharifArea,
    this.rabiCropClassification,
    this.rabiCropName,
    this.rabiArea,
    this.baseUid,
    this.parkName,
    this.parkId,
  });

  static final environmentLogger = createLogger(
    FeaturePropertiesModel,
    enableDebugLogs: AppGlobals.enableDebugLogs,
  );

  factory FeaturePropertiesModel.fromJson(Map<String, dynamic> json) {
    return FeaturePropertiesModel(
      kide: _parseToString(json['KIDE']),
      area: _parseToString(json['Area']),
      dc: _parseToString(json['DC']),
      tc: _parseToString(json['TC']),
      hc: _parseToString(json['HC']),
      vc: _parseToString(json['VC']),
      rotation: _parseToString(json['Rotation']),
      classType: _parseToString(json['Class']),
      classCat: _parseToString(json['ClassCat']),
      landId: _parseToInt(json['land_id']),
      surveyNumber: _parseToInt(json['Survey Number']),
      subdivisionNumber: _parseToString(json['Subdivision Number']),
      uniqueId1: _parseToString(json['Unique ID 1']),
      uniqueId2: _parseToString(json['Unique ID 2']),
      uidReginetAvail: _parseToInt(json['uid_reginet_avail']),
      uidTnAvail: _parseToInt(json['uid_tn_avail']),
      uidCsAvail: _parseToInt(json['uid_cs_avail']),
      reginetGuidelineValue: _parseToString(json['reginet_Guideline_Value']),
      reginetGlv: _parseToInt(json['reginet_GLV']),
      reginetUnitType: _parseToString(json['reginet_unit_type']),
      reginetLandClassification:
          _parseToString(json['reginet_Land_Classification']),
      tamilnilamPattaNumber: _parseToInt(json['tamilnilam_patta_number']),
      tamilnilamGovernmentPriority:
          _parseToString(json['tamilnilam_government_priority']),
      tamilnilamExtentAres: _parseToInt(json['tamilnilam_extent_ares']),
      tamilnilamLandType: _parseToString(json['tamilnilam_land_type']),
      tamilnilamOwnerDetails: _parseToString(json['tamilnilam_owner_details']),
      kharifCropClassification:
          _parseToString(json['kharif_crop_classification']),
      kharifCropName: _parseToString(json['kharif_crop_name']),
      kharifArea: _parseToDouble(json['kharif_area']),
      rabiCropClassification: _parseToString(json['rabi_crop_classification']),
      rabiCropName: _parseToString(json['rabi_crop_name']),
      rabiArea: _parseToDouble(json['rabi_area']),
      baseUid: _parseToString(json['base_uid']),
      parkName: _parseToString(json['Park_name']),
      parkId: _parseToInt(json['park_id']),
    );
  }

  static String? _parseToString(dynamic value) {
    if (value == null) return null;
    try {
      return value.toString();
    } catch (e) {
      environmentLogger
          .e('Error parsing string from $value (${value.runtimeType}): $e');
      return null;
    }
  }

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;

    try {
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) {
        if (value.isEmpty) return null;
        // Handle strings like "300.0" by parsing as double first
        final doubleValue = double.tryParse(value);
        return doubleValue?.round();
      }
    } catch (e) {
      environmentLogger
          .e('Error parsing int from $value (${value.runtimeType}): $e');
    }

    return null;
  }

  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;

    try {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        if (value.isEmpty) return null;
        return double.tryParse(value);
      }
    } catch (e) {
      environmentLogger
          .e('Error parsing double from $value (${value.runtimeType}): $e');
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'KIDE': kide,
      'Area': area,
      'DC': dc,
      'TC': tc,
      'HC': hc,
      'VC': vc,
      'Rotation': rotation,
      'Class': classType,
      'ClassCat': classCat,
      'land_id': landId,
      'Survey Number': surveyNumber,
      'Subdivision Number': subdivisionNumber,
      'Unique ID 1': uniqueId1,
      'Unique ID 2': uniqueId2,
      'uid_reginet_avail': uidReginetAvail,
      'uid_tn_avail': uidTnAvail,
      'uid_cs_avail': uidCsAvail,
      'reginet_Guideline_Value': reginetGuidelineValue,
      'reginet_GLV': reginetGlv,
      'reginet_unit_type': reginetUnitType,
      'reginet_Land_Classification': reginetLandClassification,
      'tamilnilam_patta_number': tamilnilamPattaNumber,
      'tamilnilam_government_priority': tamilnilamGovernmentPriority,
      'tamilnilam_extent_ares': tamilnilamExtentAres,
      'tamilnilam_land_type': tamilnilamLandType,
      'tamilnilam_owner_details': tamilnilamOwnerDetails,
      'kharif_crop_classification': kharifCropClassification,
      'kharif_crop_name': kharifCropName,
      'kharif_area': kharifArea,
      'rabi_crop_classification': rabiCropClassification,
      'rabi_crop_name': rabiCropName,
      'rabi_area': rabiArea,
      'base_uid': baseUid,
      'Park_name': parkName,
      'park_id': parkId,
    };
  }
}

class GeometryModel {
  final String type;
  final List<dynamic> coordinates;

  GeometryModel({
    required this.type,
    required this.coordinates,
  });

  factory GeometryModel.fromJson(Map<String, dynamic> json) {
    return GeometryModel(
      type: json['type'],
      coordinates: json['coordinates'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}
