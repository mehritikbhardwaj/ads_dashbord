import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/ctr_helper.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/daily_metric.dart';
import '../../../data/models/forecast_models.dart';
import '../../../data/repositories/campaign_repository.dart';

enum DetailPhase { loading, success, empty, failure }

class CampaignDetailState extends Equatable {
  const CampaignDetailState({
    required this.phase,
    this.campaign,
    this.history = const [],
    this.forecast = const [],
    this.recommendation,
    this.errorMessage,
  });

  final DetailPhase phase;
  final Campaign? campaign;
  final List<DailyMetric> history;
  final List<ForecastPoint> forecast;
  final ForecastRecommendation? recommendation;
  final String? errorMessage;

  factory CampaignDetailState.loading() =>
      const CampaignDetailState(phase: DetailPhase.loading);

  CampaignDetailState copyWith({
    DetailPhase? phase,
    Campaign? campaign,
    List<DailyMetric>? history,
    List<ForecastPoint>? forecast,
    ForecastRecommendation? recommendation,
    String? errorMessage,
  }) {
    return CampaignDetailState(
      phase: phase ?? this.phase,
      campaign: campaign ?? this.campaign,
      history: history ?? this.history,
      forecast: forecast ?? this.forecast,
      recommendation: recommendation ?? this.recommendation,
      errorMessage: errorMessage,
    );
  }

  double get headlineCtr {
    final c = campaign;
    if (c == null) return 0;
    return computeCtrRatio(impressions: c.impressions, clicks: c.clicks);
  }

  @override
  List<Object?> get props =>
      [phase, campaign, history, forecast, recommendation, errorMessage];
}

class CampaignDetailCubit extends Cubit<CampaignDetailState> {
  CampaignDetailCubit(this._repository) : super(CampaignDetailState.loading());

  final CampaignRepository _repository;

  Future<void> load(String campaignId) async {
    emit(CampaignDetailState.loading());
    try {
      final campaign = await _repository.loadCampaign(campaignId);
      final hist = await _repository.loadHistory(campaignId);
      if (hist.history.isEmpty) {
        emit(CampaignDetailState(
          phase: DetailPhase.empty,
          campaign: campaign,
          history: const [],
          forecast: const [],
        ));
        return;
      }
      final forecast = await _repository.loadForecast(
        campaignId: campaignId,
        history: hist.history,
      );
      emit(CampaignDetailState(
        phase: DetailPhase.success,
        campaign: campaign,
        history: hist.history,
        forecast: forecast.forecast,
        recommendation: forecast.recommendation,
      ));
    } catch (e) {
      emit(CampaignDetailState(
        phase: DetailPhase.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
