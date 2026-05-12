import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/anomaly.dart';
import '../../../data/repositories/anomaly_repository.dart';
import '../../../services/notification_service.dart';

abstract class AnomalyAlertsEvent extends Equatable {
  const AnomalyAlertsEvent();

  @override
  List<Object?> get props => [];
}

class AnomalyAlertsStarted extends AnomalyAlertsEvent {
  const AnomalyAlertsStarted();
}

class AnomalyAlertsPoll extends AnomalyAlertsEvent {
  const AnomalyAlertsPoll();
}

class AnomalyAlertsState extends Equatable {
  const AnomalyAlertsState({
    required this.isInitialLoading,
    required this.isPolling,
    required this.anomalies,
    this.lastChecked,
    this.errorMessage,
  });

  final bool isInitialLoading;
  final bool isPolling;
  final List<Anomaly> anomalies;
  final DateTime? lastChecked;
  final String? errorMessage;

  factory AnomalyAlertsState.initial() => const AnomalyAlertsState(
        isInitialLoading: true,
        isPolling: false,
        anomalies: [],
      );

  AnomalyAlertsState copyWith({
    bool? isInitialLoading,
    bool? isPolling,
    List<Anomaly>? anomalies,
    DateTime? lastChecked,
    String? errorMessage,
  }) {
    return AnomalyAlertsState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isPolling: isPolling ?? this.isPolling,
      anomalies: anomalies ?? this.anomalies,
      lastChecked: lastChecked ?? this.lastChecked,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [isInitialLoading, isPolling, anomalies, lastChecked, errorMessage];
}

class AnomalyAlertsBloc extends Bloc<AnomalyAlertsEvent, AnomalyAlertsState> {
  AnomalyAlertsBloc(
    this._repository,
    this._notifications,
  ) : super(AnomalyAlertsState.initial()) {
    on<AnomalyAlertsStarted>(_onStarted);
    on<AnomalyAlertsPoll>(_onPoll);
  }

  final AnomalyRepository _repository;
  final NotificationService _notifications;

  final Set<String> _seenIds = <String>{};
  bool _baselined = false;
  Timer? _timer;

  Future<void> _onStarted(
    AnomalyAlertsStarted event,
    Emitter<AnomalyAlertsState> emit,
  ) async {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => add(const AnomalyAlertsPoll()),
    );
    add(const AnomalyAlertsPoll());
  }

  Future<void> _onPoll(
    AnomalyAlertsPoll event,
    Emitter<AnomalyAlertsState> emit,
  ) async {
    emit(state.copyWith(
      isPolling: true,
      errorMessage: null,
    ));
    try {
      final snapshot = await _repository.loadLiveSnapshot();
      final result = await _repository.detect(snapshot);
      final fresh = <Anomaly>[];
      for (final a in result.anomalies) {
        if (!_baselined) {
          _seenIds.add(a.id);
          continue;
        }
        if (!_seenIds.contains(a.id)) {
          _seenIds.add(a.id);
          fresh.add(a);
        }
      }
      _baselined = true;

      for (final a in fresh) {
        final title = a.type == AnomalyType.spendSpike
            ? 'Spend spike'
            : 'CTR drop';
        await _notifications.showAnomaly(
          id: a.id.hashCode & 0x7fffffff,
          title: '$title · ${a.campaignName}',
          body: a.message,
        );
      }
      emit(state.copyWith(
        isInitialLoading: false,
        isPolling: false,
        anomalies: result.anomalies,
        lastChecked: result.checkedAt,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isInitialLoading: false,
        isPolling: false,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
