import 'anomaly.dart';

class AnomalyDetectResponse {
  const AnomalyDetectResponse({
    required this.checkedAt,
    required this.anomalyCount,
    required this.anomalies,
  });

  final DateTime checkedAt;
  final int anomalyCount;
  final List<Anomaly> anomalies;

  factory AnomalyDetectResponse.fromJson(Map<String, dynamic> json) {
    final at = DateTime.tryParse(json['checked_at'] as String? ?? '') ??
        DateTime.now().toUtc();
    final list = (json['anomalies'] as List<dynamic>? ?? [])
        .map((e) => Anomaly.fromJson(e as Map<String, dynamic>))
        .toList();
    return AnomalyDetectResponse(
      checkedAt: at.toUtc(),
      anomalyCount: (json['anomaly_count'] as num?)?.toInt() ?? list.length,
      anomalies: list,
    );
  }
}
