import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/alarm_active_screen.dart';
import '../screens/new_alarm_screen.dart';
import '../screens/record_voice_scrreen.dart';
import '../screens/select_from_storage_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String alarmActive = '/alarm-active';
  static const String newAlarm = '/new-alarm';
  static const String recordVoice = '/record-voice';
  static const String selectFromStorage = '/select-from-storage';

  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      home: (context) => const HomeScreen(),
      alarmActive: (context) => const AlarmActiveScreen(),
      newAlarm: (context) => const NewAlarmScreen(),
      recordVoice: (context) => const RecordVoiceScreen(),
      selectFromStorage: (context) => const SelectFromStorageScreen(),
    };
  }
}
