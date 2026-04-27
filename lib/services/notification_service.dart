import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Tapping the notification opens the app — no extra handling needed
        // since the app launches normally via MainActivity on tap.
      },
    );

    // On Android 13+ (API 33+), we must explicitly ask the user for
    // POST_NOTIFICATIONS permission at runtime. Without this, notifications
    // are silently dropped even if declared in AndroidManifest.xml.
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    final androidPlugin =
        notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  /// Shows an immediate notification (used when app is open).
  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'lextrack_hearing_channel',
      'Hearing Reminders',
      channelDescription: 'Daily reminders for court hearings scheduled today',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await notifications.show(1001, title, body, details);
  }

  /// Checks today's hearings and fires a notification if any exist.
  /// Called at app startup (when app IS open).
  static Future<void> checkTodayHearings(
      List<Map<String, dynamic>> hearings) async {
    if (hearings.isEmpty) return;

    final buffer = StringBuffer();
    for (var h in hearings) {
      buffer.writeln(
          "• ${h['caseNumber']}/${h['year']} — ${h['clientName']}");
    }

    await showNotification(
      "⚖️ Today's Hearings (${hearings.length})",
      buffer.toString().trim(),
    );
  }
}