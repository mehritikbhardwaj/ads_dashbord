import '../datasources/ads_remote_datasource.dart';
import '../models/summary_models.dart';

class SummaryRepository {
  SummaryRepository(this._ads);

  final AdsRemoteDataSource _ads;

  Future<SummaryResponse> loadSummary({required int days}) =>
      _ads.fetchSummary(days: days);
}
