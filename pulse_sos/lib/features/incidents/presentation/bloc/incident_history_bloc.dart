import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../sos/domain/entities/incident_entity.dart';

// ─── Events ──────────────────────────────────────────────────────────────────
abstract class IncidentHistoryEvent extends Equatable {
  const IncidentHistoryEvent();
  @override
  List<Object?> get props => [];
}

class IncidentHistoryLoadRequested extends IncidentHistoryEvent {}
class IncidentHistoryRefreshRequested extends IncidentHistoryEvent {}

// ─── States ──────────────────────────────────────────────────────────────────
abstract class IncidentHistoryState extends Equatable {
  const IncidentHistoryState();
  @override
  List<Object?> get props => [];
}

class IncidentHistoryInitial extends IncidentHistoryState {}
class IncidentHistoryLoading extends IncidentHistoryState {}

class IncidentHistoryLoaded extends IncidentHistoryState {
  final List<IncidentEntity> incidents;
  const IncidentHistoryLoaded(this.incidents);
  @override
  List<Object?> get props => [incidents];
}

class IncidentHistoryError extends IncidentHistoryState {
  final String message;
  const IncidentHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────
class IncidentHistoryBloc extends Bloc<IncidentHistoryEvent, IncidentHistoryState> {
  IncidentHistoryBloc() : super(IncidentHistoryInitial()) {
    on<IncidentHistoryLoadRequested>(_onLoadRequested);
    on<IncidentHistoryRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    IncidentHistoryLoadRequested event,
    Emitter<IncidentHistoryState> emit,
  ) async {
    emit(IncidentHistoryLoading());
    try {
      // In production: calls IncidentRepository.getIncidentHistory()
      // Here we simulate with realistic sample data
      await Future.delayed(const Duration(milliseconds: 800));

      final mockHistory = [
        IncidentEntity(
          id: 'SOS-9082',
          victimId: 'user-1',
          type: EmergencyType.robbery,
          isSilent: false,
          status: IncidentStatus.resolved,
          latitude: 37.7749,
          longitude: -122.4194,
          address: 'Broadway Ave & 5th St',
          responderCount: 2,
          responders: [],
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        IncidentEntity(
          id: 'SOS-1120',
          victimId: 'user-2',
          type: EmergencyType.medical,
          isSilent: false,
          status: IncidentStatus.resolved,
          latitude: 37.7801,
          longitude: -122.4120,
          address: '124 Market St, Sector G',
          responderCount: 1,
          responders: [],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        IncidentEntity(
          id: 'SOS-0941',
          victimId: 'user-3',
          type: EmergencyType.harassment,
          isSilent: true,
          status: IncidentStatus.falseAlarm,
          latitude: 37.7690,
          longitude: -122.4280,
          address: 'Central Plaza Mall',
          responderCount: 0,
          responders: [],
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

      emit(IncidentHistoryLoaded(mockHistory));
    } catch (e) {
      emit(IncidentHistoryError('Failed to load incident history: $e'));
    }
  }

  Future<void> _onRefreshRequested(
    IncidentHistoryRefreshRequested event,
    Emitter<IncidentHistoryState> emit,
  ) async {
    add(IncidentHistoryLoadRequested());
  }
}
