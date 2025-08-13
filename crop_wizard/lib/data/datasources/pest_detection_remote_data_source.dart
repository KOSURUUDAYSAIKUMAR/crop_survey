import 'dart:convert';
import 'dart:io'; // For SocketException
import 'package:crop_wizard/data/models/pest_detection_request_model.dart';
import 'package:crop_wizard/data/models/pest_detection_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:crop_wizard/core/constants/app_global.dart';
import 'package:crop_wizard/core/utils/custom_logger.dart';

abstract class PestDetectionRemoteDataSource {
  Future<PestDetectionResponseModel> detectPest(
      PestDetectionRequestModel requestModel);
}

class PestDetectionRemoteDataSourceImpl
    implements PestDetectionRemoteDataSource {
  final http.Client client;
  final String _endpoint =
      "https://maps-genai.demo.farmwiseai.com/api/v1/fai/mapsai/chat/process";
  final String _testEndpoint =
      "https://jsonplaceholder.typicode.com/todos/1"; // Test endpoint

  PestDetectionRemoteDataSourceImpl({required this.client});

  final environmentLogger = createLogger(
    PestDetectionRemoteDataSourceImpl,
    enableDebugLogs: AppGlobals.enableDebugLogs,
  );

  Future<void> _testNetworkConnectivity() async {
    try {
      environmentLogger.d(
          '(PestDetection) Testing network connectivity with: $_testEndpoint');
      final response = await client.get(Uri.parse(_testEndpoint));
      if (response.statusCode == 200) {
        environmentLogger.i(
            '(PestDetection) Network test successful. Status: ${response.statusCode}, Response: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
      } else {
        environmentLogger.e(
            '(PestDetection) Network test failed. Status: ${response.statusCode}');
      }
    } catch (e) {
      environmentLogger.e('(PestDetection) Network test caught exception: $e');
    }
  }

  @override
  Future<PestDetectionResponseModel> detectPest(
      PestDetectionRequestModel requestModel) async {
    await _testNetworkConnectivity();
    environmentLogger
        .d('(PestDetection) Proceeding with actual API call to: $_endpoint');
    try {
      final requestBodyJson = json.encode(requestModel.toJson());
      environmentLogger.i('(PestDetection) Request Body: $requestBodyJson');

      final response = await client.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: requestBodyJson,
      );
      environmentLogger.d("(PestDetection) API Status: ${response.statusCode}");
      environmentLogger.d("(PestDetection) API Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        if (decodedBody is Map<String, dynamic>) {
          return PestDetectionResponseModel.fromJson(decodedBody);
        } else {
          environmentLogger.w(
              '(PestDetection) API response is not a JSON object: $decodedBody');
          throw Exception(
              'Failed to parse pest detection response. Expected a JSON object.');
        }
      } else {
        throw Exception(
            'Failed to detect pest. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } on SocketException catch (e) {
      environmentLogger.e('SocketException during Pest Detection API call: $e');
      throw Exception(
          'Network error (SocketException): Could not connect to the server. Please check your internet connection and the hostname. Details: $e');
    } on http.ClientException catch (e) {
      environmentLogger.e('ClientException during Pest Detection API call: $e');
      throw Exception(
          'Network error (ClientException): There was a problem communicating with the server. Details: $e');
    } catch (e) {
      environmentLogger.e('Generic error during Pest Detection API call: $e');
      throw Exception('Failed to detect pest due to an unexpected error: $e');
    }
  }
}
