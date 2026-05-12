import 'package:equatable/equatable.dart';

enum CampaignStatus { active, paused, ended, unknown }

CampaignStatus campaignStatusFromString(String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'active':
      return CampaignStatus.active;
    case 'paused':
      return CampaignStatus.paused;
    case 'ended':
      return CampaignStatus.ended;
    default:
      return CampaignStatus.unknown;
  }
}

class Campaign extends Equatable {
  const Campaign({
    required this.id,
    required this.name,
    required this.status,
    required this.objective,
    required this.channel,
    required this.budget,
    required this.spend,
    required this.impressions,
    required this.clicks,
    required this.startDate,
    required this.endDate,
    required this.currency,
    this.thumbnail,
    this.apiCtr,
    this.budgetUtilization,
  });

  final String id;
  final String name;
  final CampaignStatus status;
  final String objective;
  final String channel;
  final double budget;
  final double spend;
  final int impressions;
  final int clicks;
  final String startDate;
  final String endDate;
  final String currency;
  final String? thumbnail;
  final double? apiCtr;
  final double? budgetUtilization;

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as String,
      name: json['name'] as String,
      status: campaignStatusFromString(json['status'] as String?),
      objective: json['objective'] as String? ?? '',
      channel: json['channel'] as String? ?? '',
      budget: (json['budget'] as num?)?.toDouble() ?? 0,
      spend: (json['spend'] as num?)?.toDouble() ?? 0,
      impressions: (json['impressions'] as num?)?.toInt() ?? 0,
      clicks: (json['clicks'] as num?)?.toInt() ?? 0,
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      currency: json['currency'] as String? ?? 'SAR',
      thumbnail: json['thumbnail'] as String?,
      apiCtr: (json['ctr'] as num?)?.toDouble(),
      budgetUtilization: (json['budget_utilization'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [id];
}
