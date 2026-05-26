import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../sos/domain/entities/incident_entity.dart';

// ─── Events ──────────────────────────────────────────────────────────────────
abstract class ResponderEvent extends Equatable {
  const ResponderEvent();
  @override
  List<Object?> get props => [];
}

class ResponderLoadNearbyIncidents extends ResponderEvent {
  final double latitude;
  final double longitude;
  final double radiusKm;

  const ResponderLoadNearbyIncidents({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 1.0,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusKm];
}

class ResponderAcceptedIncident extends ResponderEvent {
  final String incidentId;
  const ResponderAcceptedIncident(this.incidentId);
  @override
  List<Object?> get props => [incidentId];
}

class ResponderDeclinedIncident extends ResponderEvent {
  final String incidentId;
  const ResponderDeclinedIncident(this.incidentId);
  @override
  List<Object?> get props => [incidentId];
}

class ResponderArrivedAtScene extends ResponderEvent {
  final String incidentId;
  const ResponderArrivedAtScene(this.incidentId);
  @override
  List<Object?> get props => [incidentId];
}

// ─── States ──────────────────────────────────────────────────────────────────
abstract class ResponderState extends Equatable {
  const ResponderState();
  @override
  List<Object?> get props => [];
}

class ResponderIdle extends ResponderState {}
class ResponderLoading extends ResponderState {}

class ResponderNearbyLoaded extends ResponderState {
  final List<IncidentEntity> nearbyIncidents;
  const ResponderNearbyLoaded(this.nearbyIncidents);
  @override
  List<Object?> get props => [nearbyIncidents];
}

class ResponderEnRoute extends ResponderState {
  final IncidentEntity incident;
  const ResponderEnRoute(this.incident);
  @override
  List<Object?> get props => [incident];
}

class ResponderOnScene extends ResponderState {
  final IncidentEntity incident;
  const ResponderOnScene(this.incident);
  @override
  List<Object?> get props => [incident];
}

class ResponderError extends ResponderState {
  final String message;
  const ResponderError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────
class ResponderBloc extends Bloc<ResponderEvent, ResponderState> {
  ResponderBloc() : super(ResponderIdle()) {
    on<ResponderLoadNearbyIncidents>(_onLoadNearby);
    on<ResponderAcceptedIncident>(_onAccepted);
    on<ResponderDeclinedIncident>(_onDeclined);
    on<ResponderArrivedAtScene>(_onArrived);
  }

  Future<void> _onLoadNearby(
    ResponderLoadNearbyIncidents event,
    Emitter<ResponderState> emit,
  ) async {
    emit(ResponderLoading());
    try {
      // In production: calls IncidentRepository.getNearbyIncidents()
      await Future.delayed(const Duration(milliseconds: 600));

      final mockNearby = [
        IncidentEntity(
          id: 'SOS-NEAR-1',
          victimId: 'neighbor-1',
          type: EmergencyType.robbery,
          isSilent: false,
          status: IncidentStatus.active,
          latitude: event.latitude + 0.002,
          longitude: event.longitude - 0.001,
          address: '200m North-West',
          responderCount: 1,
          responders: [],
          createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
      ];

      emit(ResponderNearbyLoaded(mockNearby));
    } catch (e) {
      emit(ResponderError('Failed to load nearby incidents: $e'));
    }
  }

  Future<void> _onAccepted(
    ResponderAcceptedIncident event,
    Emitter<ResponderState> emit,
  ) async {
    final currentState = state;
    if (currentState is ResponderNearbyLoaded) {
      try {
        final incident = currentState.nearbyIncidents.firstWhere(
          (i) => i.id == event.incidentId,
        );
        emit(ResponderEnRoute(incident));
      } catch {
        emit(const ResponderError('Incident not found'));
      }
    }
  }

  Future<void> _onDeclined(
    ResponderDeclinedIncident event,
    Emitter<ResponderState> emit,
  ) async {
    final currentState = state;
    if (currentState is ResponderNearbyLoaded) {
      final filtered = currentState.nearbyIncidents
          .where((i) => i.id != event.incidentId)
          .toList();
      emit(ResponderNearbyLoaded(filtered));
    }
  }

  Future<void> _onArrived(
    ResponderArrivedAtScene event,
    Emitter<ResponderState> emit,
  ) async {
    final currentState = state;
    if (currentState is ResponderEnRoute) {
      emit(ResponderOnScene(currentState.incident));
    }
  }
}
