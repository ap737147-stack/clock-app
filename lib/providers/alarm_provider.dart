import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/alarm_model.dart';
import '../services/alarm_notification_service.dart';

// State notifier for managing alarms
class AlarmNotifier extends StateNotifier<List<AlarmModel>> {
  AlarmNotifier() : super([]) {
    _loadSavedAlarms();
  }

  Future<void> _loadSavedAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('saved_alarms');
    if (saved == null) return;

    final decoded = jsonDecode(saved);
    if (decoded is List) {
      state = decoded
          .map<AlarmModel>(
            (item) => AlarmModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    for (final alarm in state) {
      if (alarm.isActive) {
        await AlarmNotificationService.scheduleAlarmNotification(alarm);
      }
    }
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'saved_alarms',
      jsonEncode(state.map((alarm) => alarm.toJson()).toList()),
    );
  }

  Future<void> addAlarm(AlarmModel alarm) async {
    state = [...state, alarm];
    await _saveAlarms();
    await AlarmNotificationService.scheduleAlarmNotification(alarm);
  }

  Future<void> deleteAlarm(String id) async {
    await AlarmNotificationService.cancelAlarmNotification(id);
    state = state.where((alarm) => alarm.id != id).toList();
    await _saveAlarms();
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    state = state.map((a) => a.id == alarm.id ? alarm : a).toList();
    await _saveAlarms();
    await AlarmNotificationService.cancelAlarmNotification(alarm.id);
    if (alarm.isActive) {
      await AlarmNotificationService.scheduleAlarmNotification(alarm);
    }
  }

  Future<void> toggleAlarm(String id) async {
    state = state.map((alarm) {
      if (alarm.id == id) {
        return alarm.copyWith(isActive: !alarm.isActive);
      }
      return alarm;
    }).toList();
    await _saveAlarms();

    final toggled = state.firstWhere((alarm) => alarm.id == id);
    if (toggled.isActive) {
      await AlarmNotificationService.scheduleAlarmNotification(toggled);
    } else {
      await AlarmNotificationService.cancelAlarmNotification(id);
    }
  }
}

// Provider for alarm list
final alarmProvider = StateNotifierProvider<AlarmNotifier, List<AlarmModel>>((
  ref,
) {
  return AlarmNotifier();
});

// Provider for active alarm count
final activeAlarmCountProvider = Provider<int>((ref) {
  final alarms = ref.watch(alarmProvider);
  return alarms.where((alarm) => alarm.isActive).length;
});
