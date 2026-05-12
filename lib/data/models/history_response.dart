import 'daily_metric.dart';

class HistoryResponse {
  const HistoryResponse({
    required this.campaignId,
    required this.dataPoints,
    required this.history,
  });

  final String campaignId;
  final int dataPoints;
  final List<DailyMetric> history;

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['history'] as List<dynamic>? ?? [])
        .map((e) => DailyMetric.fromJson(e as Map<String, dynamic>))
        .toList();
    return HistoryResponse(
      campaignId: json['campaign_id'] as String? ?? '',
      dataPoints: (json['data_points'] as num?)?.toInt() ?? list.length,
      history: list,
    );
  }
}
