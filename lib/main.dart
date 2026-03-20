import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/hearing_reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();
  await HearingReminderService.checkTodayHearings();

  runApp(const LexTrackApp());
}

class LexTrackApp extends StatelessWidget {
  const LexTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LexTrack',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), 
    );
  }
}