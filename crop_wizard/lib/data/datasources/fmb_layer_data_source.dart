import 'package:crop_wizard/core/constants/app_global.dart';
import 'package:crop_wizard/core/utils/custom_logger.dart';
import 'package:dio/dio.dart';
import '../models/fmb_response_model.dart';

abstract class FmbLayerDataSource {
  Future<FmbResponseModel> getFmbData(String url);
}

class FmbLayerDataSourceImpl implements FmbLayerDataSource {
  final Dio dio;

  FmbLayerDataSourceImpl({required this.dio});
  final environmentLogger = createLogger(
    FmbLayerDataSourceImpl,
    enableDebugLogs: AppGlobals.enableDebugLogs,
  );

  @override
  Future<FmbResponseModel> getFmbData(String url) async {
    try {
      environmentLogger.i('Fetching FMB data from: $url');
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
        environmentLogger
            .d('Successfully fetched data. Status: ${response.statusCode}');
        if (response.data == null) {
          throw Exception('Response data is null');
        }
        if (response.data is! Map<String, dynamic>) {
          throw Exception('Response data is not a valid JSON object');
        }
        final Map<String, dynamic> jsonData =
            response.data as Map<String, dynamic>;
        return FmbResponseModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load FMB data: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      environmentLogger.e('Dio error: ${e.message}');
      environmentLogger.e('Error type: ${e.type}');
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
      environmentLogger.e('General error fetching FMB data: $e');
      throw Exception('Error processing FMB data: ${e.toString()}');
    }
  }

  Future<void> _testConnection(String url) async {
    try {
      final testDio = Dio();
      testDio.options.connectTimeout = const Duration(seconds: 5);
      testDio.options.receiveTimeout = const Duration(seconds: 60);
      await testDio.head(url);
      environmentLogger.d('Connection test successful');
    } catch (e) {
      environmentLogger.e('Connection test failed: $e');
    }
  }
}
