import 'package:crop_wizard/core/constants/app_global.dart';
import 'package:crop_wizard/core/utils/custom_logger.dart';
import 'package:dio/dio.dart';

class DioConfig {
  static final environmentLogger = createLogger(
    DioConfig,
    enableDebugLogs: AppGlobals.enableDebugLogs,
  );

  static Dio createDio() {
    final dio = Dio();

    // Configure timeout - increased for better reliability
    dio.options.connectTimeout =
        const Duration(seconds: 30); // Increased from 15 to 30
    dio.options.receiveTimeout = const Duration(seconds: 60);
    dio.options.sendTimeout = const Duration(seconds: 30); // Added send timeout

    // Add retry interceptor for better reliability
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: print,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 4),
        ],
      ),
    );

    // Add interceptor for logging and error handling
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) {
          // You can use print or your preferred logging mechanism
          environmentLogger.i(object);
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

// Retry interceptor for better network reliability
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final Function(String) logPrint;
  final int retries;
  final List<Duration> retryDelays;

  RetryInterceptor({
    required this.dio,
    required this.logPrint,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    var extra = err.requestOptions.extra;
    var retryCount = extra['retryCount'] ?? 0;

    if (_shouldRetry(err) && retryCount < retries) {
      extra['retryCount'] = retryCount + 1;
      logPrint('Retrying request (${retryCount + 1}/$retries)');

      try {
        await Future.delayed(retryDelays[retryCount]);
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        logPrint('Retry failed: $e');
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.unknown;
  }
}
