import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../database/case_database.dart';
class NotificationService {

  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await notifications.initialize(settings);
  }

  static Future<void> showNotification(String title, String body) async {

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'hearing_channel',
      'Hearing Notifications',
      channelDescription: 'Court hearing reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await notifications.show(
      0,
      title,
      body,
      details,
    );
  }

static Future<void> checkTodayHearings() async {

  List<Map<String, dynamic>> hearings =
      await CaseDatabase.getTodayHearingsWithCase();

  if (hearings.isNotEmpty) {

    String message = "";

    for (var h in hearings) {
      message +=
          "${h['caseNumber']} - ${h['clientName']}\n";
    }

    await showNotification(
      "Today's Hearings (${hearings.length})",
      message,
    );
  }
}
}