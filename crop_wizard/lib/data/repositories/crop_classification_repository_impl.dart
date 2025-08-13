import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crop_wizard/data/datasources/crop_classification_remote_data_source.dart';
import 'package:crop_wizard/data/models/crop_classification_request_model.dart';
import 'package:crop_wizard/domain/entities/crop_classification_result.dart';
import 'package:crop_wizard/domain/repositories/crop_classification_repository.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:crop_wizard/core/constants/app_global.dart';
import 'package:crop_wizard/core/utils/custom_logger.dart';

class CropClassificationRepositoryImpl implements CropClassificationRepository {
  final CropClassificationRemoteDataSource remoteDataSource;

  CropClassificationRepositoryImpl({required this.remoteDataSource});

  final environmentLogger = createLogger(
    CropClassificationRepositoryImpl,
    enableDebugLogs: AppGlobals.enableDebugLogs,
  );

  Future<Uint8List?> _compressImage(File file) async {
    final filePath = file.absolute.path;
    // Create a target path for the compressed image (optional, can work with original path too for temp files)
    // final targetPath = "${file.parent.path}/temp_${file.path.split('/').last}.jpg";

    var result = await FlutterImageCompress.compressWithFile(
      filePath,
      minWidth: 1080, // Aim for a reasonable width
      minHeight: 1080, // Aim for a reasonable height
      quality: 70, // Adjust quality (0-100)
      format: CompressFormat.jpeg, // Compress to JPEG
    );
    environmentLogger.d('Original image size: ${file.lengthSync()} bytes');
    if (result != null) {
      environmentLogger.d('Compressed image size: ${result.length} bytes');
    }
    return result;
  }

  @override
  Future<List<CropClassificationResult>> classifyCropImage(
      File imageFile) async {
    try {
      // Compress the image
      final Uint8List? compressedBytes = await _compressImage(imageFile);

      if (compressedBytes == null) {
        throw Exception('Image compression failed.');
      }

      final String base64Image = base64Encode(compressedBytes);

      final requestModel =
          CropClassificationRequestModel(baseImage: base64Image);
      final responseModels = await remoteDataSource.classifyCrop(requestModel);

      // Convert list of response models to list of base results
      return responseModels
          .map((model) => model as CropClassificationResult)
          .toList();
    } catch (e) {
      // Handle or rethrow the exception as per your app's error handling strategy
      environmentLogger.e('Error in CropClassificationRepositoryImpl: $e');
      throw Exception('Failed to process crop classification: $e');
    }
  }
}
