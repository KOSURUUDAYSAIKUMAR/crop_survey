import 'dart:io';
import 'package:crop_wizard/domain/entities/crop_classification_result.dart';
import 'package:crop_wizard/domain/usecases/classify_crop.dart';
import 'package:flutter/material.dart';

enum CropClassificationState { initial, loading, success, error }

class CropClassificationProvider with ChangeNotifier {
  final ClassifyCrop _classifyCrop;
  
  CropClassificationProvider(this._classifyCrop);

  CropClassificationState _state = CropClassificationState.initial;
  CropClassificationState get state => _state;

  CropClassificationResult? _result;
  CropClassificationResult? get result => _result;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  File? _currentImage;
  File? get currentImage => _currentImage;

  Future<void> classify(File imageFile) async {
    _currentImage = imageFile;
    _state = CropClassificationState.loading;
    notifyListeners();

    try {
      _result = await _classifyCrop(imageFile);
      _state = CropClassificationState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = CropClassificationState.error;
      print("Error in CropClassificationProvider: $e");
    }
    notifyListeners();
  }

  void resetState(){
    _state = CropClassificationState.initial;
    _result = null;
    _errorMessage = null;
    _currentImage = null;
    notifyListeners();
  }
} 