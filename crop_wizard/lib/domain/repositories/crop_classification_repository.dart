import 'dart:io';
import 'package:crop_wizard/domain/entities/crop_classification_result.dart';

abstract class CropClassificationRepository {
  Future<List<CropClassificationResult>> classifyCropImage(File imageFile);
}