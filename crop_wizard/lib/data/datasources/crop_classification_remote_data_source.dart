import 'dart:convert';
import 'dart:io'; // For SocketException, though Dio wraps it in DioException
import 'package:crop_wizard/data/models/crop_classification_request_model.dart';
import 'package:crop_wizard/data/models/crop_classification_response_model.dart';
import 'package:dio/dio.dart';

abstract class CropClassificationRemoteDataSource {
  Future<CropClassificationResponseModel> classifyCrop(CropClassificationRequestModel requestModel);
}

class CropClassificationRemoteDataSourceImpl implements CropClassificationRemoteDataSource {
  final Dio _dio;
  final String _endpoint = "https://kbodfy75f3.execute-api.ap-south-1.amazonaws.com/demo/api/cropclassification";
  final String _testEndpoint = "https://jsonplaceholder.typicode.com/todos/1";

  CropClassificationRemoteDataSourceImpl(this._dio) {
    _dio.options.connectTimeout = const Duration(seconds: 15); // 15 seconds connection timeout
    _dio.options.receiveTimeout = const Duration(seconds: 60); // 60 seconds receive timeout
  }

  Future<void> _testNetworkConnectivity() async {
    try {
      print('(Dio) Testing network connectivity with: $_testEndpoint');
      final response = await _dio.get(_testEndpoint, options: Options(receiveTimeout: const Duration(seconds:10) /* Shorter timeout for test */));
      if (response.statusCode == 200) {
        print('(Dio) Network test successful. Status: ${response.statusCode}, Response: ${response.data.toString().substring(0, response.data.toString().length > 100 ? 100 : response.data.toString().length)}...');
      } else {
        print('(Dio) Network test failed. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('(Dio) Network test caught DioException: ${e.message}');
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.unknown && e.error is SocketException) {
        print('(Dio) Network test SocketException details: ${e.error}');
      }
    } catch (e) {
      print('(Dio) Network test caught generic exception: $e');
    }
  }

  @override
  Future<CropClassificationResponseModel> classifyCrop(CropClassificationRequestModel requestModel) async {
    await _testNetworkConnectivity();
    print('(Dio) Proceeding with Crop Classification API call to: $_endpoint');

    final requestBodyMap = requestModel.toJson();
    print('(Dio) Crop Classification Request Body: ${json.encode(requestBodyMap)}');

    try {
      final response = await _dio.post(
        _endpoint,
        data: requestBodyMap,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print('(Dio) Crop Classification API Response Status: ${response.statusCode}');
      print('(Dio) Crop Classification API Response Body: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return CropClassificationResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to classify crop. Status: ${response.statusCode}, Body: ${response.data}');
      }
    } on DioException catch (e) {
      print('(Dio) DioException during Crop Classification API call: ${e.message}');
      String errorMessage = 'Network error (DioException): ${e.message}';
      if (e.type == DioExceptionType.connectionError || (e.type == DioExceptionType.unknown && e.error is SocketException)) {
        print('(Dio) Underlying SocketException: ${e.error}');
        errorMessage = 'Network error: Could not connect. Please check your internet connection and the hostname. Details: ${e.error}';
      } else if (e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) {
          errorMessage = 'Network timeout: The request took too long. Please try again. Details: ${e.message}';
      } else if (e.response != null) {
        errorMessage = 'API error: ${e.response?.statusCode} - ${e.response?.data}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('(Dio) Generic error during Crop Classification API call: $e');
      throw Exception('Failed to classify crop due to an unexpected error: $e');
    }
  }
} 