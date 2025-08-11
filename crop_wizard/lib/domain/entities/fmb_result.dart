// lib/domain/entities/fmb_result.dart
class FmbResult {
  final String? kide;
  final String? area;
  final int? surveyNumber;
  final String? subdivisionNumber;
  final String? uniqueId1;
  final String? uniqueId2;
  final String? reginetGuidelineValue;
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
  final List<dynamic> coordinates;
  final String geometryType;

  FmbResult({
    this.kide,
    this.area,
    this.surveyNumber,
    this.subdivisionNumber,
    this.uniqueId1,
    this.uniqueId2,
    this.reginetGuidelineValue,
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
    required this.coordinates,
    required this.geometryType,
  });

  /// Converts an [FmbResult] object to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'kide': kide,
      'area': area,
      'surveyNumber': surveyNumber,
      'subdivisionNumber': subdivisionNumber,
      'uniqueId1': uniqueId1,
      'uniqueId2': uniqueId2,
      'reginetGuidelineValue': reginetGuidelineValue,
      'reginetLandClassification': reginetLandClassification,
      'tamilnilamPattaNumber': tamilnilamPattaNumber,
      'tamilnilamGovernmentPriority': tamilnilamGovernmentPriority,
      'tamilnilamExtentAres': tamilnilamExtentAres,
      'tamilnilamLandType': tamilnilamLandType,
      'tamilnilamOwnerDetails': tamilnilamOwnerDetails,
      'kharifCropClassification': kharifCropClassification,
      'kharifCropName': kharifCropName,
      'kharifArea': kharifArea,
      'rabiCropClassification': rabiCropClassification,
      'rabiCropName': rabiCropName,
      'rabiArea': rabiArea,
      'baseUid': baseUid,
      'parkName': parkName,
      'coordinates': coordinates,
      'geometryType': geometryType,
    };
  }

  /// Creates an [FmbResult] object from a JSON map.
  factory FmbResult.fromJson(Map<String, dynamic> json) {
    return FmbResult(
      kide: json['kide'] as String?,
      area: json['area'] as String?,
      surveyNumber: json['surveyNumber'] as int?,
      subdivisionNumber: json['subdivisionNumber'] as String?,
      uniqueId1: json['uniqueId1'] as String?,
      uniqueId2: json['uniqueId2'] as String?,
      reginetGuidelineValue: json['reginetGuidelineValue'] as String?,
      reginetLandClassification: json['reginetLandClassification'] as String?,
      tamilnilamPattaNumber: json['tamilnilamPattaNumber'] as int?,
      tamilnilamGovernmentPriority:
          json['tamilnilamGovernmentPriority'] as String?,
      tamilnilamExtentAres: json['tamilnilamExtentAres'] as int?,
      tamilnilamLandType: json['tamilnilamLandType'] as String?,
      tamilnilamOwnerDetails: json['tamilnilamOwnerDetails'] as String?,
      kharifCropClassification: json['kharifCropClassification'] as String?,
      kharifCropName: json['kharifCropName'] as String?,
      kharifArea: json['kharifArea'] as double?,
      rabiCropClassification: json['rabiCropClassification'] as String?,
      rabiCropName: json['rabiCropName'] as String?,
      rabiArea: json['rabiArea'] as double?,
      baseUid: json['baseUid'] as String?,
      parkName: json['parkName'] as String?,
      coordinates: List<dynamic>.from(json['coordinates']),
      geometryType: json['geometryType'] as String,
    );
  }

  Map<String, dynamic> toDisplayMap() {
    return {
      'KIDE': kide ?? 'N/A',
      'Area': area ?? 'N/A',
      'Survey Number': surveyNumber?.toString() ?? 'N/A',
      'Subdivision Number': subdivisionNumber ?? 'N/A',
      'Unique ID 1': uniqueId1 ?? 'N/A',
      'Unique ID 2': uniqueId2 ?? 'N/A',
      'Guideline Value': reginetGuidelineValue ?? 'N/A',
      'Land Classification': reginetLandClassification ?? 'N/A',
      'Patta Number': tamilnilamPattaNumber?.toString() ?? 'N/A',
      'Government Priority': tamilnilamGovernmentPriority ?? 'N/A',
      'Extent (Ares)': tamilnilamExtentAres?.toString() ?? 'N/A',
      'Land Type': tamilnilamLandType ?? 'N/A',
      'Owner Details': tamilnilamOwnerDetails ?? 'N/A',
      'Kharif Crop Classification': kharifCropClassification ?? 'N/A',
      'Kharif Crop Name': kharifCropName ?? 'N/A',
      'Kharif Area': kharifArea?.toString() ?? 'N/A',
      'Rabi Crop Classification': rabiCropClassification ?? 'N/A',
      'Rabi Crop Name': rabiCropName ?? 'N/A',
      'Rabi Area': rabiArea?.toString() ?? 'N/A',
      'Base UID': baseUid ?? 'N/A',
      'Park Name': parkName ?? 'N/A',
    };
  }
}
