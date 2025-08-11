import 'dart:io';
import 'package:crop_wizard/domain/entities/crop_classification_result.dart';
import 'package:crop_wizard/domain/repositories/crop_classification_repository.dart';

class ClassifyCrop {
  final CropClassificationRepository repository;

  ClassifyCrop(this.repository);

  Future<List<CropClassificationResult>> call(File imageFile) async {
    return await repository.classifyCropImage(imageFile);
  }
}