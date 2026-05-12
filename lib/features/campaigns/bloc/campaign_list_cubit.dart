import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/ctr_helper.dart';
import '../../../data/models/campaign.dart';
import '../../../data/repositories/campaign_repository.dart';

enum CampaignFilter { all, active, paused, ended }

class CampaignListState extends Equatable {
  const CampaignListState({
    required this.filter,
    required this.isLoading,
    required this.campaigns,
    required this.filtered,
    required this.query,
    this.errorMessage,
  });

  final CampaignFilter filter;
  final bool isLoading;
  final List<Campaign> campaigns;
  final List<Campaign> filtered;
  final String query;
  final String? errorMessage;

  factory CampaignListState.initial() => const CampaignListState(
        filter: CampaignFilter.all,
        isLoading: true,
        campaigns: [],
        filtered: [],
        query: '',
      );

  CampaignListState copyWith({
    CampaignFilter? filter,
    bool? isLoading,
    List<Campaign>? campaigns,
    List<Campaign>? filtered,
    String? query,
    String? errorMessage,
  }) {
    return CampaignListState(
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      campaigns: campaigns ?? this.campaigns,
      filtered: filtered ?? this.filtered,
      query: query ?? this.query,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [filter, isLoading, campaigns, filtered, query, errorMessage];
}

class CampaignListCubit extends Cubit<CampaignListState> {
  CampaignListCubit(this._repository) : super(CampaignListState.initial());

  final CampaignRepository _repository;

  /// CTR ratio for UI: prefer client-side clicks/impressions, fallback to API.
  double ctrFor(Campaign c) {
    final computed = computeCtrRatio(
      impressions: c.impressions,
      clicks: c.clicks,
    );
    if (c.impressions > 0) return computed;
    return c.apiCtr ?? 0;
  }

  Future<void> refresh() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final list = await _repository.loadCampaigns();
      emit(state.copyWith(
        isLoading: false,
        campaigns: list,
        filtered: _apply(list, state.filter, state.query),
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void setFilter(CampaignFilter filter) {
    emit(state.copyWith(
      filter: filter,
      filtered: _apply(state.campaigns, filter, state.query),
    ));
  }

  void setQuery(String query) {
    emit(state.copyWith(
      query: query,
      filtered: _apply(state.campaigns, state.filter, query),
    ));
  }

  List<Campaign> _apply(List<Campaign> all, CampaignFilter f, String query) {
    Iterable<Campaign> result = all;
    switch (f) {
      case CampaignFilter.all:
        break;
      case CampaignFilter.active:
        result = result.where((c) => c.status == CampaignStatus.active);
        break;
      case CampaignFilter.paused:
        result = result.where((c) => c.status == CampaignStatus.paused);
        break;
      case CampaignFilter.ended:
        result = result.where((c) => c.status == CampaignStatus.ended);
        break;
    }
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.objective.toLowerCase().contains(q) ||
            c.channel.toLowerCase().contains(q);
      });
    }
    return result.toList();
  }
}
