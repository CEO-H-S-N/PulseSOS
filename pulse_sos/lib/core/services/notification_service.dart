import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

/// FCM + Local Notifications service
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();

  String? _deviceToken;
  String? get deviceToken => _deviceToken;

  /// Initialize notification channels and listeners
  Future<void> initialize() async {
    // Request permissions
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
      provisional: false,
    );

    _logger.i('Notification permission: ${settings.authorizationStatus}');

    // Get device token
    _deviceToken = await _fcm.getToken();
    _logger.i('FCM Token: $_deviceToken');

    // Token refresh listener
    _fcm.onTokenRefresh.listen((token) {
      _deviceToken = token;
      _logger.i('FCM Token refreshed');
    });

    // Configure local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels
    await _createNotificationChannels();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Emergency channel - high priority with custom sound
      await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
        'emergency_alerts',
        'Emergency Alerts',
        description: 'Critical emergency SOS alerts from nearby users',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ));

      // Responder updates channel
      await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
        'responder_updates',
        'Responder Updates',
        description: 'Updates about incident responses',
        importance: Importance.high,
      ));

      // System notifications channel
      await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
        'system_notifications',
        'System Notifications',
        description: 'General app notifications',
        importance: Importance.defaultImportance,
      ));

      // Safe check-in reminders
      await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
        'safe_checkin',
        'Safe Check-in',
        description: 'Periodic safety check-in reminders',
        importance: Importance.low,
      ));
    }
  }

  /// Show emergency alert notification (max priority)
  Future<void> showEmergencyNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'emergency_alerts',
          'Emergency Alerts',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          ticker: 'EMERGENCY SOS ALERT',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
        ),
      ),
    );
  }

  /// Show regular notification
  Future<void> showNotification({
    required String title,
    required String body,
    String channelId = 'system_notifications',
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(channelId, channelId),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _logger.i('Foreground message: ${message.messageId}');
    final notification = message.notification;
    if (notification != null) {
      final isEmergency = message.data['type'] == 'emergency';
      if (isEmergency) {
        showEmergencyNotification(
          title: notification.title ?? 'Emergency Alert',
          body: notification.body ?? 'Someone nearby needs help!',
          data: message.data,
        );
      } else {
        showNotification(
          title: notification.title ?? 'PulseSOS',
          body: notification.body ?? '',
        );
      }
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    _logger.i('Message opened app: ${message.data}');
    // Navigation handled by router based on data payload
  }

  void _onNotificationTap(NotificationResponse response) {
    _logger.i('Notification tapped: ${response.payload}');
  }
}
