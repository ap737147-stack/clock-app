// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/alarm_notification_service.dart';
import 'utils/app_theme.dart';
import 'utils/app_routes.dart';
import 'screens/home_screen.dart';
import 'screens/new_alarm_screen.dart';
import 'screens/record_voice_scrreen.dart';
import 'screens/alarm_active_screen.dart';
import 'screens/select_from_storage_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AlarmNotificationService.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ProviderScope(child: VoiceAlarmApp()));
}

class VoiceAlarmApp extends StatelessWidget {
  const VoiceAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AlarmNotificationService.navigatorKey,
      title: 'Voice Alarm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.newAlarm: (_) => const NewAlarmScreen(),
        AppRoutes.recordVoice: (_) => const RecordVoiceScreen(),
        AppRoutes.alarmActive: (_) => const AlarmActiveScreen(),
        AppRoutes.selectFromStorage: (_) => const SelectFromStorageScreen(),
      },
    );
  }
}
