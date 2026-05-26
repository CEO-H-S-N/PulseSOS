import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shake_detector/shake_detector.dart';
import 'package:logger/logger.dart';

/// Background service for SOS detection (shake, hardware buttons)
/// Runs as Android foreground service to survive app backgrounding
class BackgroundSOSService {
  static final Logger _logger = Logger();
  ShakeDetector? _shakeDetector;
  bool _isRunning = false;
  Function()? _onSOSTrigger;

  bool get isRunning => _isRunning;

  /// Initialize the foreground task for Android
  Future<void> initialize() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'pulse_sos_bg',
        channelName: 'PulseSOS Protection',
        channelDescription: 'PulseSOS is monitoring for emergencies',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        visibility: NotificationVisibility.VISIBILITY_SECRET,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  /// Start background monitoring
  Future<void> start({required Function() onSOSTrigger}) async {
    _onSOSTrigger = onSOSTrigger;

    // Start shake detection
    _startShakeDetection();

    // Start foreground task
    final result = await FlutterForegroundTask.startService(
      notificationTitle: 'PulseSOS Active',
      notificationText: 'Your safety shield is on',
      callback: _backgroundTaskCallback,
    );

    _isRunning = result is ServiceRequestSuccess;
    _logger.i('Background SOS service started: $_isRunning');
  }

  void _startShakeDetection() {
    _shakeDetector?.stopListening();
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: () {
        _logger.w('SHAKE DETECTED - Triggering SOS!');
        _onSOSTrigger?.call();
      },
      minimumShakeCount: 3,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: 2.7,
    );
  }

  /// Stop background monitoring
  Future<void> stop() async {
    _shakeDetector?.stopListening();
    _shakeDetector = null;
    await FlutterForegroundTask.stopService();
    _isRunning = false;
    _logger.i('Background SOS service stopped');
  }

  void dispose() {
    stop();
  }
}

// Top-level callback for foreground task isolate
@pragma('vm:entry-point')
void _backgroundTaskCallback() {
  FlutterForegroundTask.setTaskHandler(_SOSTaskHandler());
}

class _SOSTaskHandler extends TaskHandler {
  final Logger _logger = Logger();
  int _eventCount = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _logger.i('Background SOS handler started');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _eventCount++;
    // Periodic health check - every 5 seconds
    if (_eventCount % 12 == 0) {
      _logger.d('Background SOS service heartbeat: ${_eventCount ~/ 12} min');
    }
    // Send data back to main isolate if needed
    FlutterForegroundTask.sendDataToMain({'heartbeat': _eventCount});
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    _logger.i('Background SOS handler destroyed');
  }
}
