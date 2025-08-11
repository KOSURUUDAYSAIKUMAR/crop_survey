// lib/presentation/provider/fmb_provider_enhanced.dart
import 'package:flutter/material.dart';
import '../../domain/entities/fmb_result.dart';
import '../../domain/usecases/fmb_data.dart';

class FmbProvider extends ChangeNotifier {
  final FmbDataUseCase fmbDataUseCase;

  FmbProvider({required this.fmbDataUseCase});

  List<FmbResult> _fmbResults = [];
  List<FmbResult> _filteredResults = [];
  bool _isLoading = false;
  String? _error;

  // Filter states
  String? _selectedKharifCrop;
  String? _selectedRabiCrop;
  String? _selectedLandType;

  List<String> _availableKharifCrops = [];
  List<String> _availableRabiCrops = [];
  List<String> _availableLandTypes = [];

  // Getters
  List<FmbResult> get fmbResults => _fmbResults;
  List<FmbResult> get filteredResults => _filteredResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedKharifCrop => _selectedKharifCrop;
  String? get selectedRabiCrop => _selectedRabiCrop;
  String? get selectedLandType => _selectedLandType;
  List<String> get availableKharifCrops => _availableKharifCrops;
  List<String> get availableRabiCrops => _availableRabiCrops;
  List<String> get availableLandTypes => _availableLandTypes;

  Future<void> loadFmbData(String url) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Starting to load FMB data from: $url');

      _fmbResults = await fmbDataUseCase.getFmbDataWithFilters(url: url);
      _filteredResults = List.from(_fmbResults);

      print('Successfully loaded ${_fmbResults.length} FMB results');

      // Update available filter options safely
      _updateFilterOptions();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error in loadFmbData: $e');
      _error = _getUserFriendlyError(e.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateFilterOptions() {
    try {
      // Get unique crops and land types
      Set<String> kharifCrops = {};
      Set<String> rabiCrops = {};
      Set<String> landTypes = {};

      for (final result in _fmbResults) {
        if (result.kharifCropName != null &&
            result.kharifCropName!.isNotEmpty) {
          kharifCrops.add(result.kharifCropName!);
        }
        if (result.rabiCropName != null && result.rabiCropName!.isNotEmpty) {
          rabiCrops.add(result.rabiCropName!);
        }
        if (result.tamilnilamLandType != null &&
            result.tamilnilamLandType!.isNotEmpty) {
          landTypes.add(result.tamilnilamLandType!);
        }
      }

      _availableKharifCrops = ['All', ...kharifCrops.toList()..sort()];
      _availableRabiCrops = ['All', ...rabiCrops.toList()..sort()];
      _availableLandTypes = ['All', ...landTypes.toList()..sort()];

      print('Filter options updated:');
      print('Kharif crops: $_availableKharifCrops');
      print('Rabi crops: $_availableRabiCrops');
      print('Land types: $_availableLandTypes');
    } catch (e) {
      print('Error updating filter options: $e');
      // Set default values if error occurs
      _availableKharifCrops = ['All'];
      _availableRabiCrops = ['All'];
      _availableLandTypes = ['All'];
    }
  }

  String _getUserFriendlyError(String errorMessage) {
    if (errorMessage.contains('type \'double\' is not a subtype')) {
      return 'Data format error: The server data contains mixed number formats. Please contact support.';
    } else if (errorMessage.contains('Connection timeout')) {
      return 'Connection timeout. Please check your internet connection and try again.';
    } else if (errorMessage.contains('Network error')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorMessage.contains('Server error')) {
      return 'Server is temporarily unavailable. Please try again later.';
    } else if (errorMessage.contains('Failed to load FMB data')) {
      return 'Unable to load land survey data. Please try again.';
    } else {
      return 'An unexpected error occurred. Please try again later.';
    }
  }

  void setKharifCropFilter(String? crop) {
    _selectedKharifCrop = crop;
    if (crop != null && crop != 'All') {
      _selectedRabiCrop = null;
    }
    _applyFilters();
    notifyListeners();
  }

  void setRabiCropFilter(String? crop) {
    _selectedRabiCrop = crop;
    if (crop != null && crop != 'All') {
      _selectedKharifCrop = null;
    }
    _applyFilters();
    notifyListeners();
  }

  void setLandTypeFilter(String? landType) {
    _selectedLandType = landType;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _selectedKharifCrop = null;
    _selectedRabiCrop = null;
    _selectedLandType = null;
    _filteredResults = List.from(_fmbResults);
    notifyListeners();
  }

  void _applyFilters() {
    try {
      _filteredResults = _fmbResults.where((result) {
        bool kharifMatch = _selectedKharifCrop == null ||
            _selectedKharifCrop == 'All' ||
            result.kharifCropName == _selectedKharifCrop;

        bool rabiMatch = _selectedRabiCrop == null ||
            _selectedRabiCrop == 'All' ||
            result.rabiCropName == _selectedRabiCrop;

        bool landTypeMatch = _selectedLandType == null ||
            _selectedLandType == 'All' ||
            result.tamilnilamLandType == _selectedLandType;

        return kharifMatch && rabiMatch && landTypeMatch;
      }).toList();

      print(
          'Applied filters: ${_filteredResults.length} results out of ${_fmbResults.length}');
    } catch (e) {
      print('Error applying filters: $e');
      // If filter fails, show all results
      _filteredResults = List.from(_fmbResults);
    }
  }

  void refreshData() {
    if (_fmbResults.isNotEmpty) {
      const defaultUrl =
          'https://main.d35889sospji4x.amplifyapp.com/sipcot/data/villages/site_1_kangeyam/fmb.geojson';
      loadFmbData(defaultUrl);
    }
  }

  // Method to get statistics
  Map<String, int> getDataStatistics() {
    final stats = <String, int>{};

    try {
      stats['Total Parcels'] = _fmbResults.length;
      stats['Filtered Parcels'] = _filteredResults.length;

      // Count by land type
      final landTypeCounts = <String, int>{};
      for (final result in _filteredResults) {
        final landType = result.tamilnilamLandType ?? 'Unknown';
        landTypeCounts[landType] = (landTypeCounts[landType] ?? 0) + 1;
      }

      stats.addAll(landTypeCounts);
    } catch (e) {
      print('Error calculating statistics: $e');
    }

    return stats;
  }
}
