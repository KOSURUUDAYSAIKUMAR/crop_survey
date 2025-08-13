import 'dart:io';
import 'package:crop_wizard/domain/entities/crop_classification_result.dart';
import 'package:crop_wizard/domain/usecases/classify_crop.dart';
import 'package:flutter/material.dart';
import 'package:crop_wizard/core/constants/app_global.dart';
import 'package:crop_wizard/core/utils/custom_logger.dart';

enum CropClassificationState { initial, loading, success, error }

class CropClassificationProvider with ChangeNotifier {
  final ClassifyCrop _classifyCrop;

  CropClassificationProvider(this._classifyCrop);

  CropClassificationState _state = CropClassificationState.initial;
  CropClassificationState get state => _state;

  List<CropClassificationResult> _results = [];
  List<CropClassificationResult> get results => _results;
  CropClassificationResult? get firstResult =>
      _results.isNotEmpty ? _results.first : null;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  File? _currentImage;
  File? get currentImage => _currentImage;
  final environmentLogger = createLogger(
    CropClassificationProvider,
    enableDebugLogs: AppGlobals.enableDebugLogs,
  );

  Future<void> classify(File imageFile) async {
    _currentImage = imageFile;
    _state = CropClassificationState.loading;
    _results = [];
    _errorMessage = null;
    notifyListeners();

    try {
      _results = await _classifyCrop(imageFile);
      if (_results.isEmpty) {
        throw Exception('No crop classification results found');
      }
      _state = CropClassificationState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = CropClassificationState.error;
      environmentLogger.e("Error in CropClassificationProvider: $e");
    }
    notifyListeners();
  }

  void resetState() {
    _state = CropClassificationState.initial;
    _results = [];
    _errorMessage = null;
    _currentImage = null;
    notifyListeners();
  }
}
