import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/alarm_model.dart';
import '../utils/app_routes.dart';

class AlarmNotificationService {
  AlarmNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> init() async {
    tz.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );
  }

  static Future<void> scheduleAlarmNotification(AlarmModel alarm) async {
    if (!alarm.isActive) return;

    final scheduledDate = alarm.nextScheduledDate;
    if (scheduledDate == null) return;

    final payload = jsonEncode(alarm.toJson());
    final notificationDate = tz.TZDateTime.from(scheduledDate, tz.local);
    final androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarms',
      channelDescription: 'Voice alarm reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ticker: 'Alarm',
      fullScreenIntent: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    await _plugin.zonedSchedule(
      id: alarm.id.hashCode,
      title: alarm.title,
      body: alarm.voiceLabel != null
          ? 'Tap to play your voice alarm'
          : 'Tap to open the alarm',
      scheduledDate: notificationDate,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: alarm.repeatType == RepeatType.daily
          ? DateTimeComponents.time
          : null,
    );
  }

  static Future<void> cancelAlarmNotification(String alarmId) async {
    await _plugin.cancel(id: alarmId.hashCode);
  }

  static void _handleNotificationResponse(NotificationResponse response) {
    if (response.payload == null || response.payload!.isEmpty) return;

    try {
      final alarm = AlarmModel.fromJson(
        jsonDecode(response.payload!) as Map<String, dynamic>,
      );

      navigatorKey.currentState?.pushNamed(
        AppRoutes.alarmActive,
        arguments: alarm,
      );
    } catch (_) {
      // Ignore invalid payloads.
    }
  }
}
