import 'package:equatable/equatable.dart';

class CropClassificationResult extends Equatable {
  final String crop;
  final String confidenceScore;
  final String stageOfGrowth;
  final String description;

  const CropClassificationResult({
    required this.crop,
    required this.confidenceScore,
    required this.stageOfGrowth,
    required this.description,
  });

  @override
  List<Object?> get props => [crop, confidenceScore, stageOfGrowth, description];
} 