import 'dart:io';
import 'package:crop_wizard/domain/entities/pest_detection_result.dart';

abstract class PestDetectionRepository {
  Future<PestDetectionResult> detectPestInImage(File imageFile, String userId);
} 