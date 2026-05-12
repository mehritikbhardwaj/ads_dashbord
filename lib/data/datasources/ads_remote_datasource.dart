import 'package:dio/dio.dart';

import '../../core/errors/app_exception.dart';
import '../models/campaign.dart';
import '../models/history_response.dart';
import '../models/live_snapshot.dart';
import '../models/summary_models.dart';

class AdsRemoteDataSource {
  AdsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Campaign>> fetchCampaigns() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/campaigns');
      final data = res.data;
      if (data == null) throw const AppException('Empty campaigns response');
      final list = data['campaigns'] as List<dynamic>? ?? [];
      return list
          .map((e) => Campaign.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw AppException(_mapDio(e), cause: e);
    } catch (e) {
      throw AppException('Failed to load campaigns', cause: e);
    }
  }

  Future<Campaign> fetchCampaign(String id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/campaigns/$id');
      final data = res.data;
      if (data == null) throw const AppException('Empty campaign response');
      final c = data['campaign'] as Map<String, dynamic>?;
      if (c == null) throw const AppException('Missing campaign object');
      return Campaign.fromJson(c);
    } on DioException catch (e) {
      throw AppException(_mapDio(e), cause: e);
    } catch (e) {
      throw AppException('Failed to load campaign', cause: e);
    }
  }

  Future<HistoryResponse> fetchHistory(String campaignId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/campaigns/$campaignId/history',
      );
      final data = res.data;
      if (data == null) throw const AppException('Empty history response');
      return HistoryResponse.fromJson(data);
    } on DioException catch (e) {
      throw AppException(_mapDio(e), cause: e);
    } catch (e) {
      throw AppException('Failed to load history', cause: e);
    }
  }

  Future<SummaryResponse> fetchSummary({required int days}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/campaigns/summary',
        queryParameters: {'days': days},
      );
      final data = res.data;

      if (data == null) throw const AppException('Empty summary response');
      return SummaryResponse.fromJson(data);
    } on DioException catch (e) {
      throw AppException(_mapDio(e), cause: e);
    } catch (e) {
      throw AppException('Failed to load summary', cause: e);
    }
  }

  Future<LiveSnapshot> fetchLiveMetrics() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/campaigns/metrics/live',
      );
      final data = res.data;

      if (data == null) throw const AppException('Empty live metrics response');
      return LiveSnapshot.fromJson(data);
    } on DioException catch (e) {
      throw AppException(_mapDio(e), cause: e);
    } catch (e) {
      throw AppException('Failed to load live metrics', cause: e);
    }
  }

  String _mapDio(DioException e) {
    final status = e.response?.statusCode;
    final msg = e.response?.data?.toString();
    if (status != null) return 'Request failed ($status). $msg';
    return e.message ?? 'Network error';
  }
}
