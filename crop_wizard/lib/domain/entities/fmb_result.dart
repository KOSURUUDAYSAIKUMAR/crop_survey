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
