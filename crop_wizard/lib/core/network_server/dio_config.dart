// lib/core/network/dio_config.dart
import 'package:dio/dio.dart';

class DioConfig {
  static Dio createDio() {
    final dio = Dio();

    // Configure timeout
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 60);

    // Add interceptor for logging and error handling
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) {
          // You can use print or your preferred logging mechanism
          print(object);
        },
      ),
    );

    // Add custom error interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          String errorMessage = 'Unknown error occurred';

          if (error.type == DioExceptionType.connectionTimeout) {
            errorMessage =
                'Connection timeout. Please check your internet connection.';
          } else if (error.type == DioExceptionType.receiveTimeout) {
            errorMessage =
                'Receive timeout. The server is taking too long to respond.';
          } else if (error.type == DioExceptionType.badResponse) {
            errorMessage = 'Server error: ${error.response?.statusCode}';
          } else if (error.type == DioExceptionType.cancel) {
            errorMessage = 'Request was cancelled';
          } else if (error.type == DioExceptionType.unknown) {
            errorMessage =
                'Network error. Please check your internet connection.';
          }

          handler.next(DioException(
            requestOptions: error.requestOptions,
            message: errorMessage,
            type: error.type,
          ));
        },
      ),
    );

    return dio;
  }
}
