import 'package:dio/dio.dart';

class NetworkUtils {
  static Future<bool> testConnectivity(String url) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      print('Testing connectivity to: $url');

      // Try a HEAD request first
      final response = await dio.head(url);
      print('Connectivity test successful: ${response.statusCode}');
      return true;
    } catch (e) {
      print('Connectivity test failed: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> diagnoseNetwork(String url) async {
    final result = <String, dynamic>{};

    try {
      // Test basic connectivity
      result['connectivity'] = await testConnectivity(url);

      // Test with different timeouts
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 5);

      final stopwatch = Stopwatch()..start();
      try {
        await dio.get(url);
        stopwatch.stop();
        result['response_time'] = stopwatch.elapsedMilliseconds;
        result['fast_response'] = true;
      } catch (e) {
        stopwatch.stop();
        result['response_time'] = stopwatch.elapsedMilliseconds;
        result['fast_response'] = false;
        result['error'] = e.toString();
      }
    } catch (e) {
      result['error'] = e.toString();
    }

    return result;
  }
}
