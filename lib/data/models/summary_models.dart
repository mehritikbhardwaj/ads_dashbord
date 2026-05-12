import 'package:equatable/equatable.dart';

class ChannelSpend extends Equatable {
  const ChannelSpend({
    required this.channel,
    required this.spend,
    required this.impressions,
    required this.clicks,
  });

  final String channel;
  final double spend;
  final int impressions;
  final int clicks;

  factory ChannelSpend.fromJson(Map<String, dynamic> json) {
    return ChannelSpend(
      channel: json['channel'] as String? ?? '',
      spend: (json['spend'] as num?)?.toDouble() ?? 0,
      impressions: (json['impressions'] as num?)?.toInt() ?? 0,
      clicks: (json['clicks'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [channel];
}

class TopCampaignCtr extends Equatable {
  const TopCampaignCtr({
    required this.id,
    required this.name,
    required this.ctr,
    required this.spend,
  });

  final String id;
  final String name;
  final double ctr;
  final double spend;

  factory TopCampaignCtr.fromJson(Map<String, dynamic> json) {
    return TopCampaignCtr(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      ctr: (json['ctr'] as num?)?.toDouble() ?? 0,
      spend: (json['spend'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [id];
}

class SummaryPayload {
  const SummaryPayload({
    required this.totalSpend,
    required this.totalImpressions,
    required this.totalClicks,
    required this.overallCtr,
    required this.byChannel,
    required this.topCampaigns,
  });

  final double totalSpend;
  final int totalImpressions;
  final int totalClicks;
  final double overallCtr;
  final List<ChannelSpend> byChannel;
  final List<TopCampaignCtr> topCampaigns;

  factory SummaryPayload.fromJson(Map<String, dynamic> json) {
    final channels = (json['by_channel'] as List<dynamic>? ?? [])
        .map((e) => ChannelSpend.fromJson(e as Map<String, dynamic>))
        .toList();
    final top = (json['top_campaigns'] as List<dynamic>? ?? [])
        .map((e) => TopCampaignCtr.fromJson(e as Map<String, dynamic>))
        .toList();
    return SummaryPayload(
      totalSpend: (json['total_spend'] as num?)?.toDouble() ?? 0,
      totalImpressions: (json['total_impressions'] as num?)?.toInt() ?? 0,
      totalClicks: (json['total_clicks'] as num?)?.toInt() ?? 0,
      overallCtr: (json['overall_ctr'] as num?)?.toDouble() ?? 0,
      byChannel: channels,
      topCampaigns: top,
    );
  }
}

class SummaryResponse {
  const SummaryResponse({required this.range, required this.summary});

  final String range;
  final SummaryPayload summary;

  factory SummaryResponse.fromJson(Map<String, dynamic> json) {
    return SummaryResponse(
      range: json['range'] as String? ?? '',
      summary: SummaryPayload.fromJson(
        json['summary'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}
