import 'package:crop_survey/Repository/district_repository.dart';
import 'package:crop_survey/model/district_feature_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';

class DistrictVm with ChangeNotifier {
  MapController? _mapController;
  final DistrictRepository _repository;
  DistrictFeatureResponse? _wfsResponse;
  bool _isLoading = false;
  bool _mapReady = false;
  String? _error;

  DistrictVm(this._repository);

  MapController? get mapController => _mapController;
  DistrictFeatureResponse? get wfsResponse => _wfsResponse;
  bool get isLoading => _isLoading;
  bool get mapReady => _mapReady;
  String? get error => _error;

  void initMapController() {
    _mapController ??= MapController();
  }

  void disposeMapController() {
    _mapController?.dispose();
    _mapController = null;
  }

  Future<void> fetchWFSData() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wfsResponse = await _repository.fetchWFSData();
      _mapReady = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onMapReady() {
    if (!_mapReady) {
      _mapReady = true;
      notifyListeners();
    }
  }

  // MARK: - Selected Feature
  DistrictFeatureModel? _selectedFeature;
  DistrictFeatureModel? get selectedFeature => _selectedFeature;

  void selectFeature(DistrictFeatureModel feature) {
    _selectedFeature = feature;
    notifyListeners();
  }

  void clearSelection() {
    _selectedFeature = null;
    notifyListeners();
  }
}
