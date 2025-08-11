import 'package:crop_wizard/domain/entities/pest_detection_result.dart';

class PestDetectionResponseModel extends PestDetectionResult {
  const PestDetectionResponseModel({
    required super.geoInfo,
    required super.message,
    required super.layerName,
  });

  factory PestDetectionResponseModel.fromJson(Map<String, dynamic> json) {
    return PestDetectionResponseModel(
      geoInfo: json['Geoinfo'] as String? ?? '',
      message: PestDetectionMessage.fromJson(
          json['message'] as Map<String, dynamic>? ?? {}),
      layerName: json['layer_name'] as String? ?? '',
    );
  }
  // toJson is inherited from PestDetectionResult if needed, or can be overridden
}
