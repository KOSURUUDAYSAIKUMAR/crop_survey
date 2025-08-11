// lib/data/datasources/fmb_layer_data_source.dart
import 'package:dio/dio.dart';
import '../models/fmb_response_model.dart';

abstract class FmbLayerDataSource {
  Future<FmbResponseModel> getFmbData(String url);
}

class FmbLayerDataSourceImpl implements FmbLayerDataSource {
  final Dio dio;

  FmbLayerDataSourceImpl({required this.dio});

  @override
  Future<FmbResponseModel> getFmbData(String url) async {
    try {
      print('Fetching FMB data from: $url');

      // Test connection first
      await _testConnection(url);

      final response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.json,
          headers: {
            'Accept': 'application/json, text/plain, */*',
            'Content-Type': 'application/json',
            'User-Agent': 'CropWizard/1.0 (Flutter)',
            'Cache-Control': 'no-cache',
          },
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Successfully fetched data. Status: ${response.statusCode}');

        // Validate response data
        if (response.data == null) {
          throw Exception('Response data is null');
        }

        if (response.data is! Map<String, dynamic>) {
          throw Exception('Response data is not a valid JSON object');
        }

        final Map<String, dynamic> jsonData =
            response.data as Map<String, dynamic>;

        // Log the structure for debugging
        print('Response structure:');
        print('Type: ${jsonData['type']}');
        print('Features count: ${jsonData['features']?.length ?? 0}');

        return FmbResponseModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load FMB data: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      print('Error type: ${e.type}');

      String errorMessage = 'Network error occurred';
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage =
              'Connection timeout. Please check your internet connection.';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Server response timeout. Please try again.';
          break;
        case DioExceptionType.badResponse:
          errorMessage =
              'Server error (${e.response?.statusCode}). Please try again later.';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request was cancelled.';
          break;
        case DioExceptionType.unknown:
          errorMessage =
              'Network error. Please check your internet connection.';
          break;
        default:
          errorMessage = 'An unexpected error occurred: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('General error fetching FMB data: $e');
      throw Exception('Error processing FMB data: ${e.toString()}');
    }
  }

  // Test connection before making the actual request
  Future<void> _testConnection(String url) async {
    try {
      final testDio = Dio();
      testDio.options.connectTimeout = const Duration(seconds: 5);
      testDio.options.receiveTimeout = const Duration(seconds: 5);

      // Try a HEAD request first to test connectivity
      await testDio.head(url);
      print('Connection test successful');
    } catch (e) {
      print('Connection test failed: $e');
      // Don't throw here, let the main request handle it
    }
  }
}
