import '../entities/fmb_result.dart';
import '../../data/models/fmb_request_model.dart';

abstract class FmbRepository {
  Future<List<FmbResult>> getFmbData(FmbRequestModel request);
}
