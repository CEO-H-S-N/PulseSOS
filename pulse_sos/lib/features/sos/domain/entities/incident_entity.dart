import 'package:equatable/equatable.dart';

/// Incident entity - core domain model for SOS events
class IncidentEntity extends Equatable {
  final String id;
  final String victimId;
  final String victimName;
  final String? victimPhoto;
  final EmergencyType type;
  final UrgencyLevel urgency;
  final IncidentStatus status;
  final double latitude;
  final double longitude;
  final String? address;
  final String? geoHash;
  final List<LocationPoint> locationHistory;
  final List<ResponderInfo> responders;
  final List<RecordingInfo> recordings;
  final List<AuditEntry> auditLog;
  final double radius;
  final bool isSilent;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const IncidentEntity({
    required this.id,
    required this.victimId,
    required this.victimName,
    this.victimPhoto,
    required this.type,
    this.urgency = UrgencyLevel.high,
    this.status = IncidentStatus.triggered,
    required this.latitude,
    required this.longitude,
    this.address,
    this.geoHash,
    this.locationHistory = const [],
    this.responders = const [],
    this.recordings = const [],
    this.auditLog = const [],
    this.radius = 1.0,
    this.isSilent = false,
    required this.createdAt,
    this.resolvedAt,
  });

  /// Distance from a given point in km
  double? distanceFrom(double lat, double lng) {
    // Haversine formula simplified
    const double earthRadius = 6371;
    final dLat = _toRadians(lat - latitude);
    final dLng = _toRadians(lng - longitude);
    final a = _sin2(dLat / 2) +
        _cos(latitude) * _cos(lat) * _sin2(dLng / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double deg) => deg * 3.14159265359 / 180;
  double _sin2(double x) {
    final s = _sin(x);
    return s * s;
  }
  double _sin(double x) => x - (x*x*x)/6 + (x*x*x*x*x)/120; // Taylor approx
  double _cos(double x) => 1 - (x*x)/2 + (x*x*x*x)/24;
  double _sqrt(double x) => x <= 0 ? 0 : _newtonSqrt(x, x / 2, 0);
  double _newtonSqrt(double x, double guess, int i) =>
    i > 10 ? guess : _newtonSqrt(x, (guess + x / guess) / 2, i + 1);
  double _atan2(double y, double x) => y / (x + 0.0001); // rough approx

  bool get isActive =>
      status == IncidentStatus.triggered ||
      status == IncidentStatus.acknowledged ||
      status == IncidentStatus.respondersIncoming;

  int get responderCount => responders.where((r) => r.status == 'accepted').length;

  @override
  List<Object?> get props => [id, status, latitude, longitude, createdAt];
}

enum EmergencyType {
  robbery,
  medical,
  fire,
  harassment,
  accident,
  kidnapping,
  other;

  String get label {
    switch (this) {
      case EmergencyType.robbery: return 'Robbery';
      case EmergencyType.medical: return 'Medical Emergency';
      case EmergencyType.fire: return 'Fire';
      case EmergencyType.harassment: return 'Harassment';
      case EmergencyType.accident: return 'Accident';
      case EmergencyType.kidnapping: return 'Kidnapping';
      case EmergencyType.other: return 'Other Emergency';
    }
  }

  String get icon {
    switch (this) {
      case EmergencyType.robbery: return '🔫';
      case EmergencyType.medical: return '🏥';
      case EmergencyType.fire: return '🔥';
      case EmergencyType.harassment: return '⚠️';
      case EmergencyType.accident: return '🚗';
      case EmergencyType.kidnapping: return '🚨';
      case EmergencyType.other: return '❗';
    }
  }
}

enum UrgencyLevel {
  low,
  medium,
  high,
  critical;

  String get label {
    switch (this) {
      case UrgencyLevel.low: return 'Low';
      case UrgencyLevel.medium: return 'Medium';
      case UrgencyLevel.high: return 'High';
      case UrgencyLevel.critical: return 'CRITICAL';
    }
  }
}

enum IncidentStatus {
  triggered,
  acknowledged,
  respondersIncoming,
  resolved,
  escalated,
  falseAlarm;

  String get label {
    switch (this) {
      case IncidentStatus.triggered: return 'Triggered';
      case IncidentStatus.acknowledged: return 'Acknowledged';
      case IncidentStatus.respondersIncoming: return 'Responders Incoming';
      case IncidentStatus.resolved: return 'Resolved';
      case IncidentStatus.escalated: return 'Escalated';
      case IncidentStatus.falseAlarm: return 'False Alarm';
    }
  }
}

class LocationPoint extends Equatable {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [latitude, longitude, timestamp];
}

class ResponderInfo extends Equatable {
  final String uid;
  final String name;
  final String? photoUrl;
  final String status; // accepted, declined, arrived, helping
  final String role; // general, medical, security
  final double? latitude;
  final double? longitude;
  final DateTime? arrivedAt;

  const ResponderInfo({
    required this.uid,
    required this.name,
    this.photoUrl,
    required this.status,
    this.role = 'general',
    this.latitude,
    this.longitude,
    this.arrivedAt,
  });

  @override
  List<Object?> get props => [uid, status];
}

class RecordingInfo extends Equatable {
  final String url;
  final String type; // audio, video
  final int durationSeconds;
  final DateTime timestamp;

  const RecordingInfo({
    required this.url,
    required this.type,
    this.durationSeconds = 0,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [url, type, timestamp];
}

class AuditEntry extends Equatable {
  final String action;
  final String by;
  final String? details;
  final DateTime timestamp;

  const AuditEntry({
    required this.action,
    required this.by,
    this.details,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [action, by, timestamp];
}
