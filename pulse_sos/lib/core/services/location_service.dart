import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'dart:async';

/// Location service for GPS tracking with emergency/normal modes
class LocationService {
  final Logger _logger = Logger();
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastPosition;
  bool _isEmergencyMode = false;

  Position? get lastPosition => _lastPosition;
  bool get isEmergencyMode => _isEmergencyMode;

  /// Check and request location permissions
  Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _logger.w('Location services are disabled');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _logger.w('Location permissions denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _logger.e('Location permissions permanently denied');
      return false;
    }

    return true;
  }

  /// Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return null;

      _lastPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return _lastPosition;
    } catch (e) {
      _logger.e('Error getting current position: $e');
      return null;
    }
  }

  /// Start continuous tracking
  void startTracking({
    required Function(Position) onPosition,
    bool emergencyMode = false,
  }) {
    _isEmergencyMode = emergencyMode;
    _positionSubscription?.cancel();

    final intervalMs = emergencyMode ? 3000 : 30000;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: emergencyMode ? 1 : 10,
        intervalDuration: Duration(milliseconds: intervalMs),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'PulseSOS Active',
          notificationText: 'Tracking your location for safety',
          enableWakeLock: true,
        ),
      ),
    ).listen(
      (position) {
        _lastPosition = position;
        onPosition(position);
      },
      onError: (error) {
        _logger.e('Location stream error: $error');
      },
    );
  }

  /// Switch to emergency high-frequency mode
  void activateEmergencyMode(Function(Position) onPosition) {
    startTracking(onPosition: onPosition, emergencyMode: true);
  }

  /// Switch back to normal tracking
  void deactivateEmergencyMode(Function(Position) onPosition) {
    startTracking(onPosition: onPosition, emergencyMode: false);
  }

  /// Stop all tracking
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isEmergencyMode = false;
  }

  /// Calculate distance between two points in km
  double distanceBetween(
    double startLat, double startLng,
    double endLat, double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) / 1000;
  }

  void dispose() {
    stopTracking();
  }
}
