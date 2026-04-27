import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:workmanager/workmanager.dart';

// ─────────────────────────────────────────────────────────────────────────────
// IMPORTANT: This function runs in a SEPARATE ISOLATE from the main app.
// It has NO access to Flutter widgets, BuildContext, or any running state.
// It can only use: sqflite, flutter_local_notifications, dart:core packages.
// ─────────────────────────────────────────────────────────────────────────────

const String hearingReminderTask = "hearing_daily_reminder";

/// Called by Android/Workmanager when our background task fires.
/// This is a top-level function (not inside a class) — required by Workmanager.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == hearingReminderTask) {
      await _runHearingReminderTask();
    }
    return Future.value(true); // true = task succeeded
  });
}

/// Queries SQLite directly (no CaseDatabase class needed) and fires
/// a system notification for each hearing scheduled today.
Future<void> _runHearingReminderTask() async {
  // 1. Init notifications plugin in this isolate
  final plugin = FlutterLocalNotificationsPlugin();

  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  await plugin.initialize(
    const InitializationSettings(android: androidSettings),
  );

  // 2. Open the SQLite database directly
  final dbPath = join(await getDatabasesPath(), 'cases.db');
  final db = await openDatabase(dbPath);

  // 3. Build today's date string in d/M/yyyy format (matches app's format)
  final now = DateTime.now();
  final today = "${now.day}/${now.month}/${now.year}";

  // 4. Query hearings joined with case info
  final rows = await db.rawQuery('''
    SELECT hearings.date, hearings.stage,
           cases.caseNumber, cases.year, cases.clientName, cases.courtName
    FROM hearings
    INNER JOIN cases ON hearings.caseId = cases.id
    WHERE hearings.date = ?
  ''', [today]);

  await db.close();

  if (rows.isEmpty) return; // Nothing today — no notification needed

  // 5. Build notification body
  final buffer = StringBuffer();
  for (final h in rows) {
    buffer.writeln(
        "• ${h['caseNumber']}/${h['year']} — ${h['clientName']} (${h['courtName']})");
  }

  // 6. Fire the notification — this appears in the status bar even when
  //    the app is completely closed, just like WhatsApp/Instagram
  const androidDetails = AndroidNotificationDetails(
    'lextrack_hearing_channel',     // channel id
    'Hearing Reminders',            // channel name (shown in Settings)
    channelDescription: 'Daily reminders for court hearings scheduled today',
    importance: Importance.max,     // heads-up (pops on screen)
    priority: Priority.high,
    styleInformation: BigTextStyleInformation(''), // allows multiline body
    playSound: true,
    enableVibration: true,
    icon: '@mipmap/ic_launcher',
  );

  await plugin.show(
    1001,                           // unique notification id
    "⚖️ Today's Hearings (${rows.length})",
    buffer.toString().trim(),
    const NotificationDetails(android: androidDetails),
  );
}

/// ─── Registration ─────────────────────────────────────────────────────────
/// Call this once from main() when the app launches.
/// Workmanager persists the schedule in Android's WorkManager DB —
/// so even after the app is killed, Android wakes it at the right time.
class BackgroundService {
  static Future<void> registerDailyReminder() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // set true to test immediately in dev
    );

    // Cancel any existing task first (prevents duplicates on re-launch)
    await Workmanager().cancelByUniqueName(hearingReminderTask);

    // Register a periodic task that runs once every day
    // Android enforces a minimum of 15 minutes for periodic tasks,
    // but 1 day is perfect for a morning hearing reminder.
    await Workmanager().registerPeriodicTask(
      hearingReminderTask,           // unique name (used for dedup)
      hearingReminderTask,           // task name passed to executeTask()
      frequency: const Duration(hours: 24),
      initialDelay: _delayUntil8AM(),
      constraints: Constraints(
        networkType: NetworkType.not_required, // works fully offline
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  /// Calculates how long to wait until the next 8:00 AM.
  /// If it's already past 8 AM today, it waits until 8 AM tomorrow.
  static Duration _delayUntil8AM() {
    final now = DateTime.now();
    DateTime next8AM = DateTime(now.year, now.month, now.day, 8, 0, 0);

    if (now.isAfter(next8AM)) {
      next8AM = next8AM.add(const Duration(days: 1));
    }

    return next8AM.difference(now);
  }
}