import 'package:dio/dio.dart';
import 'core/network/dio_client.dart';
import 'data/datasources/ads_remote_datasource.dart';
import 'data/datasources/ml_remote_datasource.dart';
import 'data/repositories/anomaly_repository.dart';
import 'data/repositories/campaign_repository.dart';
import 'data/repositories/summary_repository.dart';

/// Wires remote data sources and repositories for injection into blocs / router.
class AppDependencies {
  AppDependencies({Dio? dio}) : dio = dio ?? DioClient.create() {
    ads = AdsRemoteDataSource(this.dio);
    ml = MlRemoteDataSource(this.dio);
    campaigns = CampaignRepository(ads: ads, ml: ml);
    summary = SummaryRepository(ads);
    anomalies = AnomalyRepository(ads: ads, ml: ml);
  }

  final Dio dio;
  late final AdsRemoteDataSource ads;
  late final MlRemoteDataSource ml;
  late final CampaignRepository campaigns;
  late final SummaryRepository summary;
  late final AnomalyRepository anomalies;
}
