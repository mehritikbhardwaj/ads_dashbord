import 'package:dio/dio.dart';

import '../../core/errors/app_exception.dart';
import '../models/anomaly_response.dart';
import '../models/daily_metric.dart';
import '../models/forecast_models.dart';

class MlRemoteDataSource {
  MlRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ForecastResponse> forecastCtr({
    required String campaignId,
    required List<DailyMetric> history,
    int horizonDays = 7,
  }) async {
    try {
      final body = {
        'campaign_id': campaignId,
        'history': history.map((e) => e.toForecastHistoryJson()).toList(),
        'horizon_days': horizonDays,
      };
      final res =
          await _dio.post<Map<String, dynamic>>('/forecast/ctr', data: body);
      final data = res.data;
      if (data == null) throw const AppException('Empty forecast response');
      return ForecastResponse.fromJson(data);
    } on DioException catch (e) {
      throw AppException(_mapDio(e), cause: e);
    } catch (e) {
      throw AppException('Failed to load forecast', cause: e);
    }
  }

  Future<AnomalyDetectResponse> detectAnomalies(
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/anomaly/detect',
        data: body,
      );
      final data = res.data;
      if (data == null) throw const AppException('Empty anomaly response');
      return AnomalyDetectResponse.fromJson(data);
    } on DioException catch (e) {
      throw AppException(_mapDio(e), cause: e);
    } catch (e) {
      throw AppException('Failed to detect anomalies', cause: e);
    }
  }

  String _mapDio(DioException e) {
    final status = e.response?.statusCode;
    final msg = e.response?.data?.toString();
    if (status != null) return 'Request failed ($status). $msg';
    return e.message ?? 'Network error';
  }
}
