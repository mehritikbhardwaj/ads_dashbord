import 'package:equatable/equatable.dart';

class LiveCampaignMetric extends Equatable {
  const LiveCampaignMetric({
    required this.id,
    required this.impressionsLastHour,
    required this.clicksLastHour,
    required this.spendLastHour,
    required this.ctrLastHour,
  });

  final String id;
  final int impressionsLastHour;
  final int clicksLastHour;
  final double spendLastHour;
  final double ctrLastHour;

  factory LiveCampaignMetric.fromJson(Map<String, dynamic> json) {
    return LiveCampaignMetric(
      id: json['id'] as String? ?? '',
      impressionsLastHour:
          (json['impressions_last_hour'] as num?)?.toInt() ?? 0,
      clicksLastHour: (json['clicks_last_hour'] as num?)?.toInt() ?? 0,
      spendLastHour: (json['spend_last_hour'] as num?)?.toDouble() ?? 0,
      ctrLastHour: (json['ctr_last_hour'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'impressions_last_hour': impressionsLastHour,
        'clicks_last_hour': clicksLastHour,
        'spend_last_hour': spendLastHour,
        'ctr_last_hour': ctrLastHour,
      };

  @override
  List<Object?> get props => [id];
}

class LiveSnapshot {
  const LiveSnapshot({required this.timestamp, required this.campaigns});

  final DateTime timestamp;
  final List<LiveCampaignMetric> campaigns;

  factory LiveSnapshot.fromJson(Map<String, dynamic> json) {
    final ts = DateTime.tryParse(json['timestamp'] as String? ?? '') ??
        DateTime.now().toUtc();
    final list = (json['campaigns'] as List<dynamic>? ?? [])
        .map((e) => LiveCampaignMetric.fromJson(e as Map<String, dynamic>))
        .toList();
    return LiveSnapshot(timestamp: ts.toUtc(), campaigns: list);
  }

  Map<String, dynamic> toDetectBody() => {
        'timestamp': timestamp.toIso8601String(),
        'campaigns': campaigns.map((e) => e.toJson()).toList(),
      };
}
