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
      crop: json['crop'] as String? ?? 'N/A',
      confidenceScore: json['confidence_score'] as String? ?? 'N/A',
      stageOfGrowth: json['stage_of_growth'] as String? ?? 'N/A',
      description: json['description'] as String? ?? 'N/A',
    );
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
