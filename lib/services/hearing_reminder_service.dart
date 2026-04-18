import '../database/case_database.dart';
import 'notification_service.dart';

class HearingReminderService {
  /// Shows a notification only for today's hearings (not all hearings)
  static Future<void> checkTodayHearings() async {
    List<Map<String, dynamic>> todayHearings =
        await CaseDatabase.getTodayHearingsWithCase();

    if (todayHearings.isEmpty) return;

    // Show a single grouped notification for all today's hearings
    String title = "Today's Hearings (${todayHearings.length})";
    StringBuffer bodyBuffer = StringBuffer();

    for (var h in todayHearings) {
      bodyBuffer.writeln(
          "• ${h['caseNumber']}/${h['year']} — ${h['clientName']}");
    }

    await NotificationService.showNotification(title, bodyBuffer.toString().trim());
  }
}