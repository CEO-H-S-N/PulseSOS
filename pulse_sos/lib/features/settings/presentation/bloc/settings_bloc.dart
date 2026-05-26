import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// ─── Events ──────────────────────────────────────────────────────────────────
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class SettingsLoaded extends SettingsEvent {}

class SettingsShakeToggled extends SettingsEvent {
  final bool enabled;
  const SettingsShakeToggled(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class SettingsHardwareToggled extends SettingsEvent {
  final bool enabled;
  const SettingsHardwareToggled(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class SettingsVoiceToggled extends SettingsEvent {
  final bool enabled;
  const SettingsVoiceToggled(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class SettingsSilentDefaultToggled extends SettingsEvent {
  final bool enabled;
  const SettingsSilentDefaultToggled(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class SettingsAutoAudioToggled extends SettingsEvent {
  final bool enabled;
  const SettingsAutoAudioToggled(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class SettingsAutoVideoToggled extends SettingsEvent {
  final bool enabled;
  const SettingsAutoVideoToggled(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class SettingsAnonymousToggled extends SettingsEvent {
  final bool enabled;
  const SettingsAnonymousToggled(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class SettingsRadiusChanged extends SettingsEvent {
  final double radiusKm;
  const SettingsRadiusChanged(this.radiusKm);
  @override
  List<Object?> get props => [radiusKm];
}

// ─── State ───────────────────────────────────────────────────────────────────
class SettingsState extends Equatable {
  final bool shakeEnabled;
  final bool hardwareEnabled;
  final bool voiceEnabled;
  final bool silentDefault;
  final bool autoAudio;
  final bool autoVideo;
  final bool anonymousMode;
  final double radiusKm;

  const SettingsState({
    this.shakeEnabled = true,
    this.hardwareEnabled = true,
    this.voiceEnabled = false,
    this.silentDefault = false,
    this.autoAudio = true,
    this.autoVideo = false,
    this.anonymousMode = false,
    this.radiusKm = 1.0,
  });

  SettingsState copyWith({
    bool? shakeEnabled,
    bool? hardwareEnabled,
    bool? voiceEnabled,
    bool? silentDefault,
    bool? autoAudio,
    bool? autoVideo,
    bool? anonymousMode,
    double? radiusKm,
  }) {
    return SettingsState(
      shakeEnabled: shakeEnabled ?? this.shakeEnabled,
      hardwareEnabled: hardwareEnabled ?? this.hardwareEnabled,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      silentDefault: silentDefault ?? this.silentDefault,
      autoAudio: autoAudio ?? this.autoAudio,
      autoVideo: autoVideo ?? this.autoVideo,
      anonymousMode: anonymousMode ?? this.anonymousMode,
      radiusKm: radiusKm ?? this.radiusKm,
    );
  }

  @override
  List<Object?> get props => [
    shakeEnabled, hardwareEnabled, voiceEnabled, silentDefault,
    autoAudio, autoVideo, anonymousMode, radiusKm,
  ];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<SettingsLoaded>((event, emit) => emit(const SettingsState()));
    on<SettingsShakeToggled>((event, emit) => emit(state.copyWith(shakeEnabled: event.enabled)));
    on<SettingsHardwareToggled>((event, emit) => emit(state.copyWith(hardwareEnabled: event.enabled)));
    on<SettingsVoiceToggled>((event, emit) => emit(state.copyWith(voiceEnabled: event.enabled)));
    on<SettingsSilentDefaultToggled>((event, emit) => emit(state.copyWith(silentDefault: event.enabled)));
    on<SettingsAutoAudioToggled>((event, emit) => emit(state.copyWith(autoAudio: event.enabled)));
    on<SettingsAutoVideoToggled>((event, emit) => emit(state.copyWith(autoVideo: event.enabled)));
    on<SettingsAnonymousToggled>((event, emit) => emit(state.copyWith(anonymousMode: event.enabled)));
    on<SettingsRadiusChanged>((event, emit) => emit(state.copyWith(radiusKm: event.radiusKm)));
  }
}
