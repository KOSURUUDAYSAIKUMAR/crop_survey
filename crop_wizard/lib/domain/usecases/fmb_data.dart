// lib/domain/usecases/fmb_data.dart
import '../entities/fmb_result.dart';
import '../repositories/fmb_repository.dart';
import '../../data/models/fmb_request_model.dart';

class FmbDataUseCase {
  final FmbRepository repository;

  FmbDataUseCase({required this.repository});

  Future<List<FmbResult>> call(FmbRequestModel request) async {
    return await repository.getFmbData(request);
  }

  Future<List<FmbResult>> getFmbDataWithFilters({
    required String url,
    String? kharifCropFilter,
    String? rabiCropFilter,
    String? landTypeFilter,
  }) async {
    final request = FmbRequestModel(
      url: url,
      kharifCropFilter: kharifCropFilter,
      rabiCropFilter: rabiCropFilter,
      landTypeFilter: landTypeFilter,
    );

    return await call(request);
  }

  List<String> getUniqueKharifCrops(List<FmbResult> results) {
    final Set<String> uniqueCrops = {};
    for (final result in results) {
      if (result.kharifCropName != null) {
        uniqueCrops.add(result.kharifCropName!);
      }
    }
    return uniqueCrops.toList()..sort();
  }

  List<String> getUniqueRabiCrops(List<FmbResult> results) {
    final Set<String> uniqueCrops = {};
    for (final result in results) {
      if (result.rabiCropName != null) {
        uniqueCrops.add(result.rabiCropName!);
      }
    }
    return uniqueCrops.toList()..sort();
  }

  List<String> getUniqueLandTypes(List<FmbResult> results) {
    final Set<String> uniqueTypes = {};
    for (final result in results) {
      if (result.tamilnilamLandType != null) {
        uniqueTypes.add(result.tamilnilamLandType!);
      }
    }
    return uniqueTypes.toList()..sort();
  }
}
