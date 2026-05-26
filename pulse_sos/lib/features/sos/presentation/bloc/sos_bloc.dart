import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/incident_entity.dart';
import 'dart:async';

// ─── Events ──────────────────────────────────────────────────────────
abstract class SOSEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SOSInitiated extends SOSEvent {
  final EmergencyType type;
  final bool isSilent;
  SOSInitiated({required this.type, this.isSilent = false});
  @override
  List<Object?> get props => [type, isSilent];
}

class SOSCountdownTick extends SOSEvent {
  final int secondsRemaining;
  SOSCountdownTick(this.secondsRemaining);
  @override
  List<Object?> get props => [secondsRemaining];
}

class SOSCancelled extends SOSEvent {}

class SOSConfirmed extends SOSEvent {}

class SOSLocationUpdated extends SOSEvent {
  final double latitude;
  final double longitude;
  SOSLocationUpdated(this.latitude, this.longitude);
  @override
  List<Object?> get props => [latitude, longitude];
}

class SOSResponderJoined extends SOSEvent {
  final ResponderInfo responder;
  SOSResponderJoined(this.responder);
  @override
  List<Object?> get props => [responder];
}

class SOSStatusChanged extends SOSEvent {
  final IncidentStatus newStatus;
  SOSStatusChanged(this.newStatus);
  @override
  List<Object?> get props => [newStatus];
}

class SOSResolved extends SOSEvent {}

class SOSShakeTriggered extends SOSEvent {}

class SOSQuickTrigger extends SOSEvent {}

// ─── States ──────────────────────────────────────────────────────────
abstract class SOSState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SOSIdle extends SOSState {}

class SOSTypeSelection extends SOSState {}

class SOSCountingDown extends SOSState {
  final int secondsRemaining;
  final EmergencyType type;
  final bool isSilent;
  SOSCountingDown({
    required this.secondsRemaining,
    required this.type,
    required this.isSilent,
  });
  @override
  List<Object?> get props => [secondsRemaining, type, isSilent];
}

class SOSSending extends SOSState {}

class SOSActive extends SOSState {
  final IncidentEntity incident;
  SOSActive(this.incident);
  @override
  List<Object?> get props => [incident];
}

class SOSResolvedState extends SOSState {
  final IncidentEntity incident;
  SOSResolvedState(this.incident);
  @override
  List<Object?> get props => [incident];
}

class SOSError extends SOSState {
  final String message;
  SOSError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────────────────────
class SOSBloc extends Bloc<SOSEvent, SOSState> {
  Timer? _countdownTimer;
  EmergencyType? _selectedType;
  bool _isSilent = false;

  SOSBloc() : super(SOSIdle()) {
    on<SOSInitiated>(_onInitiated);
    on<SOSCountdownTick>(_onCountdownTick);
    on<SOSCancelled>(_onCancelled);
    on<SOSConfirmed>(_onConfirmed);
    on<SOSResponderJoined>(_onResponderJoined);
    on<SOSStatusChanged>(_onStatusChanged);
    on<SOSResolved>(_onResolved);
    on<SOSShakeTriggered>(_onShakeTriggered);
    on<SOSQuickTrigger>(_onQuickTrigger);
  }

  void _onInitiated(SOSInitiated event, Emitter<SOSState> emit) {
    _selectedType = event.type;
    _isSilent = event.isSilent;

    // Start countdown
    int remaining = 5;
    emit(SOSCountingDown(
      secondsRemaining: remaining,
      type: event.type,
      isSilent: event.isSilent,
    ));

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      if (remaining <= 0) {
        timer.cancel();
        add(SOSConfirmed());
      } else {
        add(SOSCountdownTick(remaining));
      }
    });
  }

  void _onCountdownTick(SOSCountdownTick event, Emitter<SOSState> emit) {
    if (_selectedType != null) {
      emit(SOSCountingDown(
        secondsRemaining: event.secondsRemaining,
        type: _selectedType!,
        isSilent: _isSilent,
      ));
    }
  }

  void _onCancelled(SOSCancelled event, Emitter<SOSState> emit) {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _selectedType = null;
    emit(SOSIdle());
  }

  Future<void> _onConfirmed(SOSConfirmed event, Emitter<SOSState> emit) async {
    emit(SOSSending());

    try {
      // Create incident (this will be wired to repository)
      final incident = IncidentEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        victimId: 'current_user',
        victimName: 'User',
        type: _selectedType ?? EmergencyType.other,
        urgency: UrgencyLevel.high,
        status: IncidentStatus.triggered,
        latitude: 0, // Will be filled by location service
        longitude: 0,
        radius: 1.0,
        isSilent: _isSilent,
        createdAt: DateTime.now(),
      );

      emit(SOSActive(incident));
    } catch (e) {
      emit(SOSError('Failed to send SOS: $e'));
    }
  }

  void _onResponderJoined(SOSResponderJoined event, Emitter<SOSState> emit) {
    if (state is SOSActive) {
      final current = (state as SOSActive).incident;
      final updated = IncidentEntity(
        id: current.id,
        victimId: current.victimId,
        victimName: current.victimName,
        type: current.type,
        status: IncidentStatus.respondersIncoming,
        latitude: current.latitude,
        longitude: current.longitude,
        responders: [...current.responders, event.responder],
        createdAt: current.createdAt,
      );
      emit(SOSActive(updated));
    }
  }

  void _onStatusChanged(SOSStatusChanged event, Emitter<SOSState> emit) {
    if (state is SOSActive) {
      final current = (state as SOSActive).incident;
      final updated = IncidentEntity(
        id: current.id,
        victimId: current.victimId,
        victimName: current.victimName,
        type: current.type,
        status: event.newStatus,
        latitude: current.latitude,
        longitude: current.longitude,
        responders: current.responders,
        createdAt: current.createdAt,
      );
      emit(SOSActive(updated));
    }
  }

  void _onResolved(SOSResolved event, Emitter<SOSState> emit) {
    if (state is SOSActive) {
      final current = (state as SOSActive).incident;
      final resolved = IncidentEntity(
        id: current.id,
        victimId: current.victimId,
        victimName: current.victimName,
        type: current.type,
        status: IncidentStatus.resolved,
        latitude: current.latitude,
        longitude: current.longitude,
        responders: current.responders,
        createdAt: current.createdAt,
        resolvedAt: DateTime.now(),
      );
      emit(SOSResolvedState(resolved));
    }
  }

  void _onShakeTriggered(SOSShakeTriggered event, Emitter<SOSState> emit) {
    // Quick trigger with last used type or default
    add(SOSInitiated(type: EmergencyType.other, isSilent: true));
  }

  void _onQuickTrigger(SOSQuickTrigger event, Emitter<SOSState> emit) {
    emit(SOSTypeSelection());
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
