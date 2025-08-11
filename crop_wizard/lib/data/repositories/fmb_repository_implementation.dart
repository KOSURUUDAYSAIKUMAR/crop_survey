// lib/data/repositories/fmb_repository_implementation.dart
import '../../domain/entities/fmb_result.dart';
import '../../domain/repositories/fmb_repository.dart';
import '../datasources/fmb_layer_data_source.dart';
import '../models/fmb_request_model.dart';

class FmbRepositoryImplementation implements FmbRepository {
  final FmbLayerDataSource dataSource;

  FmbRepositoryImplementation({required this.dataSource});

  @override
  Future<List<FmbResult>> getFmbData(FmbRequestModel request) async {
    try {
      final response = await dataSource.getFmbData(request.url);

      List<FmbResult> results = response.features.map((feature) {
        return FmbResult(
          kide: feature.properties.kide,
          area: feature.properties.area,
          surveyNumber: feature.properties.surveyNumber,
          subdivisionNumber: feature.properties.subdivisionNumber,
          uniqueId1: feature.properties.uniqueId1,
          uniqueId2: feature.properties.uniqueId2,
          reginetGuidelineValue: feature.properties.reginetGuidelineValue,
          reginetLandClassification:
              feature.properties.reginetLandClassification,
          tamilnilamPattaNumber: feature.properties.tamilnilamPattaNumber,
          tamilnilamGovernmentPriority:
              feature.properties.tamilnilamGovernmentPriority,
          tamilnilamExtentAres: feature.properties.tamilnilamExtentAres,
          tamilnilamLandType: feature.properties.tamilnilamLandType,
          tamilnilamOwnerDetails: feature.properties.tamilnilamOwnerDetails,
          kharifCropClassification: feature.properties.kharifCropClassification,
          kharifCropName: feature.properties.kharifCropName,
          kharifArea: feature.properties.kharifArea,
          rabiCropClassification: feature.properties.rabiCropClassification,
          rabiCropName: feature.properties.rabiCropName,
          rabiArea: feature.properties.rabiArea,
          baseUid: feature.properties.baseUid,
          parkName: feature.properties.parkName,
          coordinates: feature.geometry.coordinates,
          geometryType: feature.geometry.type,
        );
      }).toList();

      // Apply filters
      if (request.kharifCropFilter != null) {
        results = results
            .where(
                (result) => result.kharifCropName == request.kharifCropFilter)
            .toList();
      }

      if (request.rabiCropFilter != null) {
        results = results
            .where((result) => result.rabiCropName == request.rabiCropFilter)
            .toList();
      }

      if (request.landTypeFilter != null) {
        results = results
            .where(
                (result) => result.tamilnilamLandType == request.landTypeFilter)
            .toList();
      }

      return results;
    } catch (e) {
      throw Exception('Failed to get FMB data: $e');
    }
  }
}
