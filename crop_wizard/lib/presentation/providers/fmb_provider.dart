import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/fmb_result.dart';
import '../../domain/usecases/fmb_data.dart';
import '../../data/models/fmb_request_model.dart';

class FmbProvider extends ChangeNotifier {
  final FmbDataUseCase fmbDataUseCase;
  late Box<String> _fmbBox;
  bool _isHiveInitialized = false;

  // State variables
  List<FmbResult> _fmbResults = [];
  List<FmbResult> _filteredResults = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCrop;

  // Getters
  List<FmbResult> get fmbResults => _fmbResults;
  List<FmbResult> get filteredResults => _filteredResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCrop => _selectedCrop;

  // Available options for filtering
  List<String> get availableCrops {
    Set<String> crops = {'All'};
    for (final result in _fmbResults) {
      if (result.kharifCropName?.isNotEmpty == true) {
        crops.add(result.kharifCropName!);
      }
      if (result.rabiCropName?.isNotEmpty == true) {
        crops.add(result.rabiCropName!);
      }
    }
    crops.remove(''); // Remove empty strings
    return crops.toList()..sort();
  }

  FmbProvider({required this.fmbDataUseCase}) {
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      if (!_isHiveInitialized) {
        await Hive.initFlutter();
        _fmbBox = await Hive.openBox<String>('fmb_data');
        _isHiveInitialized = true;
        print('Hive initialized successfully');
      }
    } catch (e) {
      print('Error initializing Hive: $e');
      _error = 'Failed to initialize local storage: $e';
      notifyListeners();
    }
  }

  Future<void> loadFmbData(String url) async {
    try {
      await _initializeHive();

      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Loading FMB data from: $url');

      // Try to load from local storage first
      final cachedData = await _loadFromLocalStorage(url);
      if (cachedData != null && cachedData.isNotEmpty) {
        print('Loading data from local storage');
        _fmbResults = cachedData;
        _filteredResults = List.from(_fmbResults);
        _isLoading = false;
        notifyListeners();
        return;
      }

      // If no cached data, fetch from API
      print('No cached data found, fetching from API');
      final request = FmbRequestModel(url: url);
      final data = await fmbDataUseCase.call(request);

      print('FMB data loaded successfully: ${data.length} results');
      _fmbResults = data;
      _filteredResults = List.from(_fmbResults);

      // Save to local storage
      await _saveToLocalStorage(url, data);
      await _saveAsGeoJSON(data);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error in loadFmbData: $e');
      _error = 'Failed to load FMB data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToLocalStorage(String url, List<FmbResult> data) async {
    try {
      if (!_isHiveInitialized) return;

      final jsonString =
          jsonEncode(data.map((result) => result.toJson()).toList());
      await _fmbBox.put('fmb_data_$url', jsonString);
      await _fmbBox.put('last_updated', DateTime.now().toIso8601String());
      print('Data saved to local storage: ${data.length} items');
    } catch (e) {
      print('Error saving to local storage: $e');
    }
  }

  Future<List<FmbResult>?> _loadFromLocalStorage(String url) async {
    try {
      if (!_isHiveInitialized) return null;

      final jsonString = _fmbBox.get('fmb_data_$url');
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final results =
            jsonList.map((json) => FmbResult.fromJson(json)).toList();
        print('Loaded from local storage: ${results.length} items');
        return results;
      }
    } catch (e) {
      print('Error loading from local storage: $e');
    }
    return null;
  }

  Future<void> _saveAsGeoJSON(List<FmbResult> data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/fmb_data.geojson');

      final geoJson = {
        "type": "FeatureCollection",
        "features": data
            .map((result) => {
                  "type": "Feature",
                  "properties": result.toJson(),
                  "geometry": {
                    "type": "Polygon",
                    "coordinates": result.coordinates
                  }
                })
            .toList()
      };

      await file.writeAsString(jsonEncode(geoJson));
      print('GeoJSON saved to: ${file.path}');
    } catch (e) {
      print('Error saving GeoJSON: $e');
    }
  }

  Future<void> updateCropForPolygon(String kide, String newCrop) async {
    try {
      print('Updating crop for KIDE: $kide to: $newCrop');

      // Find the polygon by KIDE
      final index = _fmbResults.indexWhere((result) => result.kide == kide);
      if (index != -1) {
        // Create updated result with new crop
        final oldResult = _fmbResults[index];
        final updatedResult = FmbResult(
          kide: oldResult.kide,
          surveyNumber: oldResult.surveyNumber,
          subdivisionNumber: oldResult.subdivisionNumber,
          area: oldResult.area,
          uniqueId1: oldResult.uniqueId1,
          uniqueId2: oldResult.uniqueId2,
          reginetGuidelineValue: oldResult.reginetGuidelineValue,
          reginetLandClassification: oldResult.reginetLandClassification,
          tamilnilamPattaNumber: oldResult.tamilnilamPattaNumber,
          tamilnilamGovernmentPriority: oldResult.tamilnilamGovernmentPriority,
          tamilnilamExtentAres: oldResult.tamilnilamExtentAres,
          tamilnilamLandType: oldResult.tamilnilamLandType,
          tamilnilamOwnerDetails: oldResult.tamilnilamOwnerDetails,
          kharifCropClassification: oldResult.kharifCropClassification,
          kharifCropName: newCrop, // Update the crop
          kharifArea: oldResult.kharifArea,
          rabiCropClassification: oldResult.rabiCropClassification,
          rabiCropName: oldResult.rabiCropName,
          rabiArea: oldResult.rabiArea,
          baseUid: oldResult.baseUid,
          parkName: oldResult.parkName,
          coordinates: oldResult.coordinates,
          geometryType: oldResult.geometryType,
        );

        // Update in memory
        _fmbResults[index] = updatedResult;
        _applyFilters();

        // Update in local storage
        await _updateLocalStorage();
        await _saveAsGeoJSON(_fmbResults);

        notifyListeners();
        print('Crop updated successfully for KIDE: $kide');
      } else {
        print('No polygon found with KIDE: $kide');
      }
    } catch (e) {
      print('Error updating crop for polygon: $e');
      _error = 'Failed to update crop: $e';
      notifyListeners();
    }
  }

  Future<void> _updateLocalStorage() async {
    try {
      if (!_isHiveInitialized) return;

      // Get the original URL key (you might want to store this)
      final keys = _fmbBox.keys
          .where((key) => key.toString().startsWith('fmb_data_'))
          .toList();
      if (keys.isNotEmpty) {
        final jsonString =
            jsonEncode(_fmbResults.map((result) => result.toJson()).toList());
        await _fmbBox.put(keys.first, jsonString);
        await _fmbBox.put('last_updated', DateTime.now().toIso8601String());
        print('Local storage updated with new crop data');
      }
    } catch (e) {
      print('Error updating local storage: $e');
    }
  }

  void setCropFilter(String? crop) {
    _selectedCrop = crop;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredResults = _fmbResults.where((result) {
      // Crop filter
      if (_selectedCrop != null && _selectedCrop != 'All') {
        final hasKharifMatch = result.kharifCropName == _selectedCrop;
        final hasRabiMatch = result.rabiCropName == _selectedCrop;
        if (!hasKharifMatch && !hasRabiMatch) {
          return false;
        }
      }
      return true;
    }).toList();

    print(
        'Applied filters. Showing ${_filteredResults.length} of ${_fmbResults.length} results');
  }

  void clearFilters() {
    _selectedCrop = null;
    _filteredResults = List.from(_fmbResults);
    notifyListeners();
  }

  void refreshData() {
    // Clear local cache and reload
    _clearLocalCache();
    // You'll need to store the original URL to refresh
    // For now, we'll just reload from local storage
    _filteredResults = List.from(_fmbResults);
    notifyListeners();
  }

  Future<void> _clearLocalCache() async {
    try {
      if (!_isHiveInitialized) return;
      await _fmbBox.clear();
      print('Local cache cleared');
    } catch (e) {
      print('Error clearing local cache: $e');
    }
  }

  FmbResult? findPolygonByKide(String kide) {
    try {
      return _fmbResults.firstWhere((result) => result.kide == kide);
    } catch (e) {
      return null;
    }
  }

  List<String> getAllCropNames() {
    Set<String> crops = {};
    for (final result in _fmbResults) {
      if (result.kharifCropName?.isNotEmpty == true) {
        crops.add(result.kharifCropName!);
      }
      if (result.rabiCropName?.isNotEmpty == true) {
        crops.add(result.rabiCropName!);
      }
    }
    return crops.toList()..sort();
  }

  @override
  void dispose() {
    if (_isHiveInitialized) {
      _fmbBox.close();
    }
    super.dispose();
  }
}
