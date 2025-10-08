import 'package:crop_survey/model/district_feature_model.dart';
import 'package:dio/dio.dart';

class DistrictRepository {
  final Dio _dio = Dio();

  Future<DistrictFeatureResponse> fetchWFSData() async {
    try {
      const url =
          'https://agrex-demo.farmwiseai.com/geoserver/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=Puvi:district_boundary&outputFormat=application/json';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return DistrictFeatureResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load WFS data');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
