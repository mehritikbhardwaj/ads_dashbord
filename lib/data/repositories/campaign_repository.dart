import '../datasources/ads_remote_datasource.dart';
import '../datasources/ml_remote_datasource.dart';
import '../models/campaign.dart';
import '../models/daily_metric.dart';
import '../models/forecast_models.dart';
import '../models/history_response.dart';

class CampaignRepository {
  CampaignRepository({
    required AdsRemoteDataSource ads,
    required MlRemoteDataSource ml,
  })  : _ads = ads,
        _ml = ml;

  final AdsRemoteDataSource _ads;
  final MlRemoteDataSource _ml;

  Future<List<Campaign>> loadCampaigns() => _ads.fetchCampaigns();

  Future<Campaign> loadCampaign(String id) => _ads.fetchCampaign(id);

  Future<HistoryResponse> loadHistory(String campaignId) =>
      _ads.fetchHistory(campaignId);

  Future<ForecastResponse> loadForecast({
    required String campaignId,
    required List<DailyMetric> history,
    int horizonDays = 7,
  }) =>
      _ml.forecastCtr(
        campaignId: campaignId,
        history: history,
        horizonDays: horizonDays,
      );
}
