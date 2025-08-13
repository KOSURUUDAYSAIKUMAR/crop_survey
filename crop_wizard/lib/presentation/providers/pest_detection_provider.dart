import 'dart:io';
import 'package:crop_wizard/domain/entities/pest_detection_result.dart';
import 'package:crop_wizard/domain/usecases/detect_pest.dart';
import 'package:flutter/material.dart';
import 'package:crop_wizard/core/constants/app_global.dart';
import 'package:crop_wizard/core/utils/custom_logger.dart';

enum PestDetectionState { initial, loading, success, error }

class PestDetectionProvider with ChangeNotifier {
  final DetectPest _detectPest;
  // Hardcoding user_id for now as per the API requirement
  final String _userId = "+916379639531";

  PestDetectionProvider(this._detectPest);

  PestDetectionState _state = PestDetectionState.initial;
  PestDetectionState get state => _state;

  PestDetectionResult? _result;
  PestDetectionResult? get result => _result;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  File? _currentImage;
  File? get currentImage => _currentImage;
  final environmentLogger = createLogger(
    PestDetectionProvider,
    enableDebugLogs: AppGlobals.enableDebugLogs,
  );

  Future<void> detect(File imageFile) async {
    _currentImage = imageFile;
    _state = PestDetectionState.loading;
    notifyListeners();

    try {
      _result = await _detectPest(imageFile, _userId);
      _state = PestDetectionState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = PestDetectionState.error;
      environmentLogger.e("Error in PestDetectionProvider: $e");
    }
    notifyListeners();
  }

  void resetState() {
    _state = PestDetectionState.initial;
    _result = null;
    _errorMessage = null;
    _currentImage = null;
    notifyListeners();
  }
}
