import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/schedule.dart';

const _kChannelId = 'yakssok_medicine';
const _kChannelName = '복약 알림';

class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  static Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleForAll(List<Schedule> schedules) async {
    await _plugin.cancelAll();
    for (final s in schedules) {
      await scheduleOne(s);
    }
  }

  static Future<void> scheduleOne(Schedule schedule) async {
    if (schedule.status == ScheduleStatus.taken) return;
    if (schedule.scheduledAt.isBefore(DateTime.now())) return;

    final tzTime = tz.TZDateTime.from(schedule.scheduledAt, tz.local);

    try {
      await _plugin.zonedSchedule(
        schedule.id.hashCode.abs(),
        '${schedule.medicine.name} 복용 시간이에요 💊',
        _body(schedule),
        tzTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _kChannelId,
            _kChannelName,
            channelDescription: '복약 시간 알림',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('[Notification] 스케줄 실패: $e');
    }
  }

  static Future<void> cancel(String scheduleId) async {
    await _plugin.cancel(scheduleId.hashCode.abs());
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static String _body(Schedule s) {
    final slot = switch (s.slot) {
      ScheduleSlot.morning => '아침',
      ScheduleSlot.lunch => '점심',
      ScheduleSlot.evening => '저녁',
      ScheduleSlot.bedtime => '취침 전',
      ScheduleSlot.custom => '지정 시간',
    };
    final parts = <String>[slot];
    if (s.doseCount != null) parts.add('${s.doseCount}알');
    if (s.mealRelation != null) parts.add(s.mealRelation!);
    return parts.join(' · ');
  }
}
