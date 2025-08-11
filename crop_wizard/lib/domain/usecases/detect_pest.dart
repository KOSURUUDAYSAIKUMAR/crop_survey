import 'dart:io';
import 'package:crop_wizard/domain/entities/pest_detection_result.dart';
import 'package:crop_wizard/domain/repositories/pest_detection_repository.dart';

class DetectPest {
  final PestDetectionRepository repository;

  DetectPest(this.repository);

  Future<PestDetectionResult> call(File imageFile, String userId) async {
    // userId could be passed from a user session service in a real app
    return await repository.detectPestInImage(imageFile, userId);
  }
} 