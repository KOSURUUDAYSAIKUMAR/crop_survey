import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crop_wizard/data/datasources/pest_detection_remote_data_source.dart';
import 'package:crop_wizard/data/models/pest_detection_request_model.dart';
import 'package:crop_wizard/domain/entities/pest_detection_result.dart';
import 'package:crop_wizard/domain/repositories/pest_detection_repository.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class PestDetectionRepositoryImpl implements PestDetectionRepository {
  final PestDetectionRemoteDataSource remoteDataSource;
  // Hardcoding user_id for now as per the API requirement, ideally, this would come from user auth
  final String _userId = "+916379639531"; 

  PestDetectionRepositoryImpl({required this.remoteDataSource});

  Future<Uint8List?> _compressImage(File file) async {
    final filePath = file.absolute.path;
    var result = await FlutterImageCompress.compressWithFile(
      filePath,
      minWidth: 1080,
      minHeight: 1080,
      quality: 70,
      format: CompressFormat.jpeg,
    );
    print('Original image size for pest detection: ${file.lengthSync()} bytes');
    if (result != null) {
      print('Compressed image size for pest detection: ${result.length} bytes');
    }
    return result;
  }

  @override
  Future<PestDetectionResult> detectPestInImage(File imageFile, String userId) async {
    try {
      final Uint8List? compressedBytes = await _compressImage(imageFile);
      if (compressedBytes == null) {
        throw Exception('Image compression failed for pest detection.');
      }
      final String base64Image = base64Encode(compressedBytes);

      final requestModel = PestDetectionRequestModel(
        inputPrompt: "detect pests", 
        inputImage: base64Image, 
        userId: _userId // Using the hardcoded or passed userId
      );
      final responseModel = await remoteDataSource.detectPest(requestModel);
      return responseModel;
    } catch (e) {
      print('Error in PestDetectionRepositoryImpl: $e');
      throw Exception('Failed to process pest detection: $e');
    }
  }
} 