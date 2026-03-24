import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  static Future<bool> requestPermissions() async {
    bool granted = false;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final result = await android.requestNotificationsPermission();
      granted = result ?? false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final result = await ios.requestPermissions(
        alert: true,
        badge: false,
        sound: true,
      );
      granted = result ?? false;
    }

    return granted;
  }

  static Future<void> showScholarshipAlert({
    required String gwaDisplay,
    required String thresholdDisplay,
    required bool isCritical,
    required bool isHigherBetter,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'scholarship_alert_channel',
      'Scholarship Alerts',
      channelDescription:
          'Alerts when your GWA is at risk for your scholarship requirement',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final direction = isHigherBetter ? 'fallen below' : 'risen above';
    final severity = isCritical ? 'Your GWA ($gwaDisplay) has $direction your required threshold ($thresholdDisplay). Act now to protect your scholarship!' : 'Your GWA ($gwaDisplay) is approaching your required threshold ($thresholdDisplay). Keep it up!';

    await _plugin.show(
      1, // fixed ID so repeated alerts replace previous one
      isCritical ? 'Scholarship at Risk!' : 'GWA Getting Close',
      severity,
      details,
    );
  }

  static Future<void> cancelScholarshipAlert() async {
    await _plugin.cancel(1);
  }
}
