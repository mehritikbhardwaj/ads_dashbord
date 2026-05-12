import '../datasources/ads_remote_datasource.dart';
import '../datasources/ml_remote_datasource.dart';
import '../models/anomaly_response.dart';
import '../models/live_snapshot.dart';

class AnomalyRepository {
  AnomalyRepository({
    required AdsRemoteDataSource ads,
    required MlRemoteDataSource ml,
  })  : _ads = ads,
        _ml = ml;

  final AdsRemoteDataSource _ads;
  final MlRemoteDataSource _ml;

  Future<LiveSnapshot> loadLiveSnapshot() => _ads.fetchLiveMetrics();

  Future<AnomalyDetectResponse> detect(LiveSnapshot snapshot) =>
      _ml.detectAnomalies(snapshot.toDetectBody());
}
