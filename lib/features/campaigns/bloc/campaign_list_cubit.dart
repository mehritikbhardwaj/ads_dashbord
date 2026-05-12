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
    this.errorMessage,
  });

  final CampaignFilter filter;
  final bool isLoading;
  final List<Campaign> campaigns;
  final List<Campaign> filtered;
  final String? errorMessage;

  factory CampaignListState.initial() => const CampaignListState(
        filter: CampaignFilter.all,
        isLoading: true,
        campaigns: [],
        filtered: [],
      );

  CampaignListState copyWith({
    CampaignFilter? filter,
    bool? isLoading,
    List<Campaign>? campaigns,
    List<Campaign>? filtered,
    String? errorMessage,
  }) {
    return CampaignListState(
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      campaigns: campaigns ?? this.campaigns,
      filtered: filtered ?? this.filtered,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [filter, isLoading, campaigns, filtered, errorMessage];
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
      final filtered = _apply(list, state.filter);
      emit(state.copyWith(
        isLoading: false,
        campaigns: list,
        filtered: filtered,
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
    final filtered = _apply(state.campaigns, filter);
    emit(state.copyWith(filter: filter, filtered: filtered));
  }

  List<Campaign> _apply(List<Campaign> all, CampaignFilter f) {
    switch (f) {
      case CampaignFilter.all:
        return List.of(all);
      case CampaignFilter.active:
        return all.where((c) => c.status == CampaignStatus.active).toList();
      case CampaignFilter.paused:
        return all.where((c) => c.status == CampaignStatus.paused).toList();
      case CampaignFilter.ended:
        return all.where((c) => c.status == CampaignStatus.ended).toList();
    }
  }
}
