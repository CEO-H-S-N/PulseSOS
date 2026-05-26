import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

/// Firestore user data model with serialization
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.displayName,
    required super.phone,
    super.email,
    super.photoUrl,
    super.bloodGroup,
    super.medicalConditions,
    super.gender,
    super.vehicleDetails,
    super.homeLat,
    super.homeLng,
    super.trustLevel,
    super.helpfulnessScore,
    super.totalResponses,
    super.isVerifiedResponder,
    super.responderRole,
    super.deviceTokens,
    super.latitude,
    super.longitude,
    super.geoHash,
    super.settings,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final location = data['location'] as Map<String, dynamic>?;
    final geopoint = location?['geopoint'] as GeoPoint?;
    final settingsMap = data['settings'] as Map<String, dynamic>?;
    final vehicleMap = data['vehicleDetails'] as Map<String, dynamic>?;

    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'],
      photoUrl: data['photoUrl'],
      bloodGroup: data['bloodGroup'],
      medicalConditions: List<String>.from(data['medicalConditions'] ?? []),
      gender: data['gender'],
      vehicleDetails: vehicleMap != null
          ? VehicleDetails(
              type: vehicleMap['type'] ?? '',
              number: vehicleMap['number'] ?? '',
              color: vehicleMap['color'],
            )
          : null,
      homeLat: (data['homeArea'] as GeoPoint?)?.latitude,
      homeLng: (data['homeArea'] as GeoPoint?)?.longitude,
      trustLevel: (data['trustLevel'] ?? 50).toDouble(),
      helpfulnessScore: (data['helpfulnessScore'] ?? 0).toDouble(),
      totalResponses: data['totalResponses'] ?? 0,
      isVerifiedResponder: data['isVerifiedResponder'] ?? false,
      responderRole: data['responderRole'] ?? 'general',
      deviceTokens: List<String>.from(data['deviceTokens'] ?? []),
      latitude: geopoint?.latitude,
      longitude: geopoint?.longitude,
      geoHash: location?['geohash'],
      settings: settingsMap != null
          ? UserSettings(
              sosRadius: (settingsMap['sosRadius'] ?? 1.0).toDouble(),
              shakeEnabled: settingsMap['shakeEnabled'] ?? true,
              shakeThreshold: settingsMap['shakeThreshold'] ?? 3,
              hardwareButtonEnabled: settingsMap['hardwareButtonEnabled'] ?? true,
              voiceActivationEnabled: settingsMap['voiceActivationEnabled'] ?? false,
              silentModeDefault: settingsMap['silentModeDefault'] ?? false,
              autoRecordAudio: settingsMap['autoRecordAudio'] ?? true,
              autoRecordVideo: settingsMap['autoRecordVideo'] ?? false,
              darkMode: settingsMap['darkMode'] ?? true,
              sosCountdownSeconds: settingsMap['sosCountdownSeconds'] ?? 5,
              anonymousMode: settingsMap['anonymousMode'] ?? false,
            )
          : const UserSettings(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'bloodGroup': bloodGroup,
      'medicalConditions': medicalConditions,
      'gender': gender,
      'vehicleDetails': vehicleDetails != null
          ? {
              'type': vehicleDetails!.type,
              'number': vehicleDetails!.number,
              'color': vehicleDetails!.color,
            }
          : null,
      'homeArea': homeLat != null && homeLng != null
          ? GeoPoint(homeLat!, homeLng!)
          : null,
      'trustLevel': trustLevel,
      'helpfulnessScore': helpfulnessScore,
      'totalResponses': totalResponses,
      'isVerifiedResponder': isVerifiedResponder,
      'responderRole': responderRole,
      'deviceTokens': deviceTokens,
      'location': latitude != null && longitude != null
          ? {
              'geopoint': GeoPoint(latitude!, longitude!),
              'geohash': geoHash ?? '',
            }
          : null,
      'settings': {
        'sosRadius': settings.sosRadius,
        'shakeEnabled': settings.shakeEnabled,
        'shakeThreshold': settings.shakeThreshold,
        'hardwareButtonEnabled': settings.hardwareButtonEnabled,
        'voiceActivationEnabled': settings.voiceActivationEnabled,
        'silentModeDefault': settings.silentModeDefault,
        'autoRecordAudio': settings.autoRecordAudio,
        'autoRecordVideo': settings.autoRecordVideo,
        'darkMode': settings.darkMode,
        'sosCountdownSeconds': settings.sosCountdownSeconds,
        'anonymousMode': settings.anonymousMode,
      },
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      displayName: entity.displayName,
      phone: entity.phone,
      email: entity.email,
      photoUrl: entity.photoUrl,
      bloodGroup: entity.bloodGroup,
      medicalConditions: entity.medicalConditions,
      gender: entity.gender,
      vehicleDetails: entity.vehicleDetails,
      homeLat: entity.homeLat,
      homeLng: entity.homeLng,
      trustLevel: entity.trustLevel,
      helpfulnessScore: entity.helpfulnessScore,
      totalResponses: entity.totalResponses,
      isVerifiedResponder: entity.isVerifiedResponder,
      responderRole: entity.responderRole,
      deviceTokens: entity.deviceTokens,
      latitude: entity.latitude,
      longitude: entity.longitude,
      geoHash: entity.geoHash,
      settings: entity.settings,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
