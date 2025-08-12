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

  // JSON serialization methods
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

  factory FmbResult.fromJson(Map<String, dynamic> json) {
    return FmbResult(
      kide: json['kide']?.toString(),
      area: json['area']?.toString(),
      surveyNumber: json['surveyNumber'] is int
          ? json['surveyNumber']
          : int.tryParse(json['surveyNumber']?.toString() ?? ''),
      subdivisionNumber: json['subdivisionNumber']?.toString(),
      uniqueId1: json['uniqueId1']?.toString(),
      uniqueId2: json['uniqueId2']?.toString(),
      reginetGuidelineValue: json['reginetGuidelineValue']?.toString(),
      reginetLandClassification: json['reginetLandClassification']?.toString(),
      tamilnilamPattaNumber: json['tamilnilamPattaNumber'] is int
          ? json['tamilnilamPattaNumber']
          : int.tryParse(json['tamilnilamPattaNumber']?.toString() ?? ''),
      tamilnilamGovernmentPriority:
          json['tamilnilamGovernmentPriority']?.toString(),
      tamilnilamExtentAres: json['tamilnilamExtentAres'] is int
          ? json['tamilnilamExtentAres']
          : int.tryParse(json['tamilnilamExtentAres']?.toString() ?? ''),
      tamilnilamLandType: json['tamilnilamLandType']?.toString(),
      tamilnilamOwnerDetails: json['tamilnilamOwnerDetails']?.toString(),
      kharifCropClassification: json['kharifCropClassification']?.toString(),
      kharifCropName: json['kharifCropName']?.toString(),
      kharifArea: json['kharifArea'] is double
          ? json['kharifArea']
          : double.tryParse(json['kharifArea']?.toString() ?? ''),
      rabiCropClassification: json['rabiCropClassification']?.toString(),
      rabiCropName: json['rabiCropName']?.toString(),
      rabiArea: json['rabiArea'] is double
          ? json['rabiArea']
          : double.tryParse(json['rabiArea']?.toString() ?? ''),
      baseUid: json['baseUid']?.toString(),
      parkName: json['parkName']?.toString(),
      coordinates: json['coordinates'] ?? [],
      geometryType: json['geometryType']?.toString() ?? 'Polygon',
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

  // Helper method to get the primary crop name for display
  String get primaryCropName {
    if (kharifCropName?.isNotEmpty == true) {
      return kharifCropName!;
    } else if (rabiCropName?.isNotEmpty == true) {
      return rabiCropName!;
    }
    return 'No Crop';
  }

  // Copy method for easy updates
  FmbResult copyWith({
    String? kide,
    String? area,
    int? surveyNumber,
    String? subdivisionNumber,
    String? uniqueId1,
    String? uniqueId2,
    String? reginetGuidelineValue,
    String? reginetLandClassification,
    int? tamilnilamPattaNumber,
    String? tamilnilamGovernmentPriority,
    int? tamilnilamExtentAres,
    String? tamilnilamLandType,
    String? tamilnilamOwnerDetails,
    String? kharifCropClassification,
    String? kharifCropName,
    double? kharifArea,
    String? rabiCropClassification,
    String? rabiCropName,
    double? rabiArea,
    String? baseUid,
    String? parkName,
    List<dynamic>? coordinates,
    String? geometryType,
  }) {
    return FmbResult(
      kide: kide ?? this.kide,
      area: area ?? this.area,
      surveyNumber: surveyNumber ?? this.surveyNumber,
      subdivisionNumber: subdivisionNumber ?? this.subdivisionNumber,
      uniqueId1: uniqueId1 ?? this.uniqueId1,
      uniqueId2: uniqueId2 ?? this.uniqueId2,
      reginetGuidelineValue:
          reginetGuidelineValue ?? this.reginetGuidelineValue,
      reginetLandClassification:
          reginetLandClassification ?? this.reginetLandClassification,
      tamilnilamPattaNumber:
          tamilnilamPattaNumber ?? this.tamilnilamPattaNumber,
      tamilnilamGovernmentPriority:
          tamilnilamGovernmentPriority ?? this.tamilnilamGovernmentPriority,
      tamilnilamExtentAres: tamilnilamExtentAres ?? this.tamilnilamExtentAres,
      tamilnilamLandType: tamilnilamLandType ?? this.tamilnilamLandType,
      tamilnilamOwnerDetails:
          tamilnilamOwnerDetails ?? this.tamilnilamOwnerDetails,
      kharifCropClassification:
          kharifCropClassification ?? this.kharifCropClassification,
      kharifCropName: kharifCropName ?? this.kharifCropName,
      kharifArea: kharifArea ?? this.kharifArea,
      rabiCropClassification:
          rabiCropClassification ?? this.rabiCropClassification,
      rabiCropName: rabiCropName ?? this.rabiCropName,
      rabiArea: rabiArea ?? this.rabiArea,
      baseUid: baseUid ?? this.baseUid,
      parkName: parkName ?? this.parkName,
      coordinates: coordinates ?? this.coordinates,
      geometryType: geometryType ?? this.geometryType,
    );
  }
}
