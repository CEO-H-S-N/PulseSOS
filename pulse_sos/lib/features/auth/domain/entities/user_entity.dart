import 'package:equatable/equatable.dart';

/// Core User entity - domain layer
class UserEntity extends Equatable {
  final String uid;
  final String displayName;
  final String phone;
  final String? email;
  final String? photoUrl;
  final String? bloodGroup;
  final List<String> medicalConditions;
  final String? gender;
  final VehicleDetails? vehicleDetails;
  final double? homeLat;
  final double? homeLng;
  final double trustLevel;
  final double helpfulnessScore;
  final int totalResponses;
  final bool isVerifiedResponder;
  final String responderRole;
  final List<String> deviceTokens;
  final double? latitude;
  final double? longitude;
  final String? geoHash;
  final UserSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.uid,
    required this.displayName,
    required this.phone,
    this.email,
    this.photoUrl,
    this.bloodGroup,
    this.medicalConditions = const [],
    this.gender,
    this.vehicleDetails,
    this.homeLat,
    this.homeLng,
    this.trustLevel = 50.0,
    this.helpfulnessScore = 0.0,
    this.totalResponses = 0,
    this.isVerifiedResponder = false,
    this.responderRole = 'general',
    this.deviceTokens = const [],
    this.latitude,
    this.longitude,
    this.geoHash,
    this.settings = const UserSettings(),
    required this.createdAt,
    required this.updatedAt,
  });

  UserEntity copyWith({
    String? displayName,
    String? phone,
    String? email,
    String? photoUrl,
    String? bloodGroup,
    List<String>? medicalConditions,
    String? gender,
    VehicleDetails? vehicleDetails,
    double? homeLat,
    double? homeLng,
    double? trustLevel,
    double? helpfulnessScore,
    int? totalResponses,
    bool? isVerifiedResponder,
    String? responderRole,
    List<String>? deviceTokens,
    double? latitude,
    double? longitude,
    String? geoHash,
    UserSettings? settings,
  }) {
    return UserEntity(
      uid: uid,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      gender: gender ?? this.gender,
      vehicleDetails: vehicleDetails ?? this.vehicleDetails,
      homeLat: homeLat ?? this.homeLat,
      homeLng: homeLng ?? this.homeLng,
      trustLevel: trustLevel ?? this.trustLevel,
      helpfulnessScore: helpfulnessScore ?? this.helpfulnessScore,
      totalResponses: totalResponses ?? this.totalResponses,
      isVerifiedResponder: isVerifiedResponder ?? this.isVerifiedResponder,
      responderRole: responderRole ?? this.responderRole,
      deviceTokens: deviceTokens ?? this.deviceTokens,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geoHash: geoHash ?? this.geoHash,
      settings: settings ?? this.settings,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [uid, displayName, phone, email, updatedAt];
}

class VehicleDetails extends Equatable {
  final String type;
  final String number;
  final String? color;

  const VehicleDetails({required this.type, required this.number, this.color});

  @override
  List<Object?> get props => [type, number, color];
}

class UserSettings extends Equatable {
  final double sosRadius;
  final bool shakeEnabled;
  final int shakeThreshold;
  final bool hardwareButtonEnabled;
  final bool voiceActivationEnabled;
  final bool silentModeDefault;
  final bool autoRecordAudio;
  final bool autoRecordVideo;
  final bool darkMode;
  final int sosCountdownSeconds;
  final bool anonymousMode;

  const UserSettings({
    this.sosRadius = 1.0,
    this.shakeEnabled = true,
    this.shakeThreshold = 3,
    this.hardwareButtonEnabled = true,
    this.voiceActivationEnabled = false,
    this.silentModeDefault = false,
    this.autoRecordAudio = true,
    this.autoRecordVideo = false,
    this.darkMode = true,
    this.sosCountdownSeconds = 5,
    this.anonymousMode = false,
  });

  UserSettings copyWith({
    double? sosRadius,
    bool? shakeEnabled,
    int? shakeThreshold,
    bool? hardwareButtonEnabled,
    bool? voiceActivationEnabled,
    bool? silentModeDefault,
    bool? autoRecordAudio,
    bool? autoRecordVideo,
    bool? darkMode,
    int? sosCountdownSeconds,
    bool? anonymousMode,
  }) {
    return UserSettings(
      sosRadius: sosRadius ?? this.sosRadius,
      shakeEnabled: shakeEnabled ?? this.shakeEnabled,
      shakeThreshold: shakeThreshold ?? this.shakeThreshold,
      hardwareButtonEnabled: hardwareButtonEnabled ?? this.hardwareButtonEnabled,
      voiceActivationEnabled: voiceActivationEnabled ?? this.voiceActivationEnabled,
      silentModeDefault: silentModeDefault ?? this.silentModeDefault,
      autoRecordAudio: autoRecordAudio ?? this.autoRecordAudio,
      autoRecordVideo: autoRecordVideo ?? this.autoRecordVideo,
      darkMode: darkMode ?? this.darkMode,
      sosCountdownSeconds: sosCountdownSeconds ?? this.sosCountdownSeconds,
      anonymousMode: anonymousMode ?? this.anonymousMode,
    );
  }

  @override
  List<Object?> get props => [sosRadius, shakeEnabled, darkMode, anonymousMode];
}
