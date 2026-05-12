import 'package:equatable/equatable.dart';

class ForecastPoint extends Equatable {
  const ForecastPoint({
    required this.date,
    required this.predictedCtr,
    required this.lowerBound,
    required this.upperBound,
  });

  final String date;
  final double predictedCtr;
  final double lowerBound;
  final double upperBound;

  factory ForecastPoint.fromJson(Map<String, dynamic> json) {
    return ForecastPoint(
      date: json['date'] as String? ?? '',
      predictedCtr: (json['predicted_ctr'] as num?)?.toDouble() ?? 0,
      lowerBound: (json['lower_bound'] as num?)?.toDouble() ?? 0,
      upperBound: (json['upper_bound'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [date];
}

class ForecastRecommendation extends Equatable {
  const ForecastRecommendation({
    required this.trend,
    required this.changePercent,
    required this.message,
    this.suggestedDailyBudget,
  });

  final String trend;
  final double changePercent;
  final String message;
  final double? suggestedDailyBudget;

  factory ForecastRecommendation.fromJson(Map<String, dynamic> json) {
    return ForecastRecommendation(
      trend: json['trend'] as String? ?? '',
      changePercent: (json['change_percent'] as num?)?.toDouble() ?? 0,
      message: json['message'] as String? ?? '',
      suggestedDailyBudget:
          (json['suggested_daily_budget'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [trend, changePercent, message];
}

class ForecastResponse {
  const ForecastResponse({
    required this.campaignId,
    required this.horizonDays,
    required this.forecast,
    this.recommendation,
    this.model,
    this.generatedAt,
  });

  final String campaignId;
  final int horizonDays;
  final List<ForecastPoint> forecast;
  final ForecastRecommendation? recommendation;
  final String? model;
  final String? generatedAt;

  factory ForecastResponse.fromJson(Map<String, dynamic> json) {
    final pts = (json['forecast'] as List<dynamic>? ?? [])
        .map((e) => ForecastPoint.fromJson(e as Map<String, dynamic>))
        .toList();
    ForecastRecommendation? rec;
    final raw = json['recommendation'];
    if (raw is Map<String, dynamic>) {
      rec = ForecastRecommendation.fromJson(raw);
    }
    return ForecastResponse(
      campaignId: json['campaign_id'] as String? ?? '',
      horizonDays: (json['horizon_days'] as num?)?.toInt() ?? 7,
      forecast: pts,
      recommendation: rec,
      model: json['model'] as String?,
      generatedAt: json['generated_at'] as String?,
    );
  }
}
