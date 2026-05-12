import 'package:equatable/equatable.dart';

enum AnomalyType { spendSpike, ctrDrop, unknown }

AnomalyType anomalyTypeFromString(String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'spend_spike':
      return AnomalyType.spendSpike;
    case 'ctr_drop':
      return AnomalyType.ctrDrop;
    default:
      return AnomalyType.unknown;
  }
}

class Anomaly extends Equatable {
  const Anomaly({
    required this.id,
    required this.campaignId,
    required this.campaignName,
    required this.detectedAt,
    required this.type,
    required this.severity,
    required this.metric,
    required this.actualValue,
    required this.expectedValue,
    required this.deviationPercent,
    required this.message,
  });

  final String id;
  final String campaignId;
  final String campaignName;
  final DateTime detectedAt;
  final AnomalyType type;
  final String severity;
  final String metric;
  final double actualValue;
  final double expectedValue;
  final double deviationPercent;
  final String message;

  factory Anomaly.fromJson(Map<String, dynamic> json) {
    final dt = DateTime.tryParse(json['detected_at'] as String? ?? '') ??
        DateTime.now().toUtc();
    return Anomaly(
      id: json['id'] as String? ?? '',
      campaignId: json['campaign_id'] as String? ?? '',
      campaignName: json['campaign_name'] as String? ?? '',
      detectedAt: dt.toUtc(),
      type: anomalyTypeFromString(json['type'] as String?),
      severity: json['severity'] as String? ?? '',
      metric: json['metric'] as String? ?? '',
      actualValue: (json['actual_value'] as num?)?.toDouble() ?? 0,
      expectedValue: (json['expected_value'] as num?)?.toDouble() ?? 0,
      deviationPercent: (json['deviation_percent'] as num?)?.toDouble() ?? 0,
      message: json['message'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id];
}
