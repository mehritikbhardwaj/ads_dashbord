import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/summary_models.dart';
import '../../../data/repositories/summary_repository.dart';

class SpendSummaryState extends Equatable {
  const SpendSummaryState({
    required this.days,
    required this.isLoading,
    this.summary,
    this.errorMessage,
  });

  final int days;
  final bool isLoading;
  final SummaryPayload? summary;
  final String? errorMessage;

  factory SpendSummaryState.initial() =>
      const SpendSummaryState(days: 7, isLoading: true);

  SpendSummaryState copyWith({
    int? days,
    bool? isLoading,
    SummaryPayload? summary,
    String? errorMessage,
  }) {
    return SpendSummaryState(
      days: days ?? this.days,
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [days, isLoading, summary, errorMessage];
}

class SpendSummaryCubit extends Cubit<SpendSummaryState> {
  SpendSummaryCubit(this._repository) : super(SpendSummaryState.initial());

  final SummaryRepository _repository;

  Future<void> selectRange(int days) async {
    emit(state.copyWith(days: days, isLoading: true, errorMessage: null));
    await load();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final res = await _repository.loadSummary(days: state.days);
      emit(state.copyWith(
        isLoading: false,
        summary: res.summary,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }
}
