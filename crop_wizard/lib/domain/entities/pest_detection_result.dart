import 'package:equatable/equatable.dart';

class PestDetectionMessage extends Equatable {
  final String diseaseName;
  final String confidenceScore;
  final String nextSteps;

  const PestDetectionMessage({
    required this.diseaseName,
    required this.confidenceScore,
    required this.nextSteps,
  });

  factory PestDetectionMessage.fromJson(Map<String, dynamic> json) {
    return PestDetectionMessage(
      diseaseName: json['disease_name'] as String? ?? 'N/A',
      confidenceScore: json['confidence_score'] as String? ?? 'N/A',
      nextSteps: json['next_steps'] as String? ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disease_name': diseaseName,
      'confidence_score': confidenceScore,
      'next_steps': nextSteps,
    };
  }

  @override
  List<Object?> get props => [diseaseName, confidenceScore, nextSteps];
}

class PestDetectionResult extends Equatable {
  final String geoInfo;
  final PestDetectionMessage message;
  final String layerName;

  const PestDetectionResult({
    required this.geoInfo,
    required this.message,
    required this.layerName,
  });

  factory PestDetectionResult.fromJson(Map<String, dynamic> json) {
    return PestDetectionResult(
      geoInfo: json['Geoinfo'] as String? ?? '',
      message: PestDetectionMessage.fromJson(json['message'] as Map<String, dynamic>? ?? {}),
      layerName: json['layer_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Geoinfo': geoInfo,
      'message': message.toJson(),
      'layer_name': layerName,
    };
  }

  @override
  List<Object?> get props => [geoInfo, message, layerName];
} 