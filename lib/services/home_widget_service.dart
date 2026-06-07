import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../core/utils.dart';
import '../models/schedule.dart';

class HomeWidgetService {
  HomeWidgetService._();

  static const appGroupId = 'group.com.example.yakssokFront';
  static const iOSWidgetName = 'YakssokMedicineWidget';

  static Future<void> init() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    await HomeWidget.setAppGroupId(appGroupId);
  }

  static Future<void> updateNextMedicine(List<Schedule> schedules) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;

    final next = _nextSchedule(schedules);

    if (next == null) {
      await Future.wait([
        HomeWidget.saveWidgetData<String>('medicineName', '오늘 복용 완료'),
        HomeWidget.saveWidgetData<String>('medicineTime', '남은 약 없음'),
        HomeWidget.saveWidgetData<String>('medicineDetail', '오늘도 잘 챙겼어요'),
        HomeWidget.saveWidgetData<bool>('isMissed', false),
        HomeWidget.saveWidgetData<bool>('hasMedicine', false),
      ]);
    } else {
      await Future.wait([
        HomeWidget.saveWidgetData<String>(
          'medicineName',
          next.medicine.name,
        ),
        HomeWidget.saveWidgetData<String>(
          'medicineTime',
          AppFormat.timeOfDay12h(next.scheduledAt),
        ),
        HomeWidget.saveWidgetData<String>('medicineDetail', _subText(next)),
        HomeWidget.saveWidgetData<bool>(
          'isMissed',
          next.status == ScheduleStatus.missed,
        ),
        HomeWidget.saveWidgetData<bool>('hasMedicine', true),
      ]);
    }

    await HomeWidget.updateWidget(iOSName: iOSWidgetName);
  }

  static Schedule? _nextSchedule(List<Schedule> schedules) {
    final pending = schedules
        .where((schedule) => schedule.status != ScheduleStatus.taken)
        .toList()
      ..sort((a, b) {
        if (a.status == ScheduleStatus.missed &&
            b.status != ScheduleStatus.missed) {
          return -1;
        }
        if (a.status != ScheduleStatus.missed &&
            b.status == ScheduleStatus.missed) {
          return 1;
        }
        return a.scheduledAt.compareTo(b.scheduledAt);
      });

    return pending.isEmpty ? null : pending.first;
  }

  static String _subText(Schedule schedule) {
    final parts = <String>[];
    if (schedule.doseCount != null) parts.add('${schedule.doseCount}알');
    if (schedule.medicine.dosage != null) parts.add(schedule.medicine.dosage!);
    if (schedule.mealRelation != null) parts.add(schedule.mealRelation!);
    return parts.isEmpty ? '앱에서 복용하기' : parts.join(' • ');
  }
}
