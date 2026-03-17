import '../database/case_database.dart';
import 'notification_service.dart';

class HearingReminderService {

  static Future checkTodayHearings() async {

    List<Map<String,dynamic>> hearings =
        await CaseDatabase.getAllHearingsWithCase();

    for (var h in hearings) {

      String title = "Hearing Today";

      String body =
          "Case ${h['caseNumber']}/${h['year']} - ${h['clientName']}";

      await NotificationService.showNotification(title, body);
    }
  }
}