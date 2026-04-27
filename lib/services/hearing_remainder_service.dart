import '../database/case_database.dart';
import 'notification_service.dart';

/// Used only for the in-app trigger (when the user opens the app).
/// The background/closed-app trigger is handled by BackgroundService
/// via Workmanager — see background_service.dart.
class HearingReminderService {
  static Future<void> checkTodayHearings() async {
    final hearings = await CaseDatabase.getTodayHearingsWithCase();
    await NotificationService.checkTodayHearings(hearings);
  }
}