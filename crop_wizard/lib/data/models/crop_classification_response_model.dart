import 'package:crop_wizard/domain/entities/crop_classification_result.dart';

class CropClassificationResponseModel extends CropClassificationResult {
  const CropClassificationResponseModel({
    required super.crop,
    required super.confidenceScore,
    required super.stageOfGrowth,
    required super.description,
  });

  factory CropClassificationResponseModel.fromJson(Map<String, dynamic> json) {
    return CropClassificationResponseModel(
      crop: json['crop']?.toString() ?? 'N/A',
      confidenceScore: json['confidence_score']?.toString() ?? 'N/A',
      stageOfGrowth: json['stage_of_growth']?.toString() ?? 'N/A',
      description: json['description']?.toString() ?? 'N/A',
    );
  }

  static List<CropClassificationResponseModel> fromJsonList(
      List<dynamic> jsonList) {
    return jsonList
        .map((item) => CropClassificationResponseModel.fromJson(
            item as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'crop': crop,
      'confidence_score': confidenceScore,
      'stage_of_growth': stageOfGrowth,
      'description': description,
    };
  }
}
