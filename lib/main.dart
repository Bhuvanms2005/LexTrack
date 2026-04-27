import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'database/case_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init local notifications + request POST_NOTIFICATIONS permission
  //    (Android 13+ requires runtime permission request)
  await NotificationService.init();

  // 2. Register the daily background task with Workmanager.
  //    This persists in Android's WorkManager database — the task will
  //    fire every day at 8 AM even when the app is completely closed.
  await BackgroundService.registerDailyReminder();

  // 3. Also check today's hearings immediately on launch (app-open reminder)
  final todayHearings = await CaseDatabase.getTodayHearingsWithCase();
  await NotificationService.checkTodayHearings(todayHearings);

  runApp(const LexTrackApp());
}

class LexTrackApp extends StatelessWidget {
  const LexTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LexTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF162F4A),
          primary: const Color(0xFF162F4A),
          secondary: const Color(0xFFC9A227),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF162F4A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC9A227),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}