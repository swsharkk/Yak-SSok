import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../models/schedule.dart';
import '../../../providers/calendar_provider.dart';

/// table_calendar 래퍼. 커스텀 헤더 + 한국어 요일 + 이벤트 마커 포함.
class MedicineCalendar extends ConsumerStatefulWidget {
  const MedicineCalendar({super.key});

  @override
  ConsumerState<MedicineCalendar> createState() => _MedicineCalendarState();
}

class _MedicineCalendarState extends ConsumerState<MedicineCalendar> {
  late DateTime _focusedDay;

  static const _weekdayKr = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(calendarSelectedDateProvider);
    final events = ref.watch(calendarMonthEventsProvider).valueOrNull ?? {};

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMd,
        AppDimensions.paddingLg,
        AppDimensions.paddingMd,
        AppDimensions.paddingSm,
      ),
      child: Column(
        children: [
          _CalendarHeader(
            focusedMonth: _focusedDay,
            onPrev: _goPrev,
            onNext: _goNext,
          ),
          const SizedBox(height: AppDimensions.paddingMd),
          TableCalendar<Schedule>(
            firstDay: DateTime(2024, 1, 1),
            lastDay: DateTime(2027, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, selectedDate),
            eventLoader: (day) {
              final key = DateTime(day.year, day.month, day.day);
              return events[key] ?? [];
            },
            onDaySelected: (selected, focused) {
              setState(() => _focusedDay = focused);
              ref.read(calendarSelectedDateProvider.notifier).select(selected);
            },
            onPageChanged: (focused) {
              setState(() => _focusedDay = focused);
              ref.read(calendarFocusedMonthProvider.notifier).go(focused);
            },
            startingDayOfWeek: StartingDayOfWeek.sunday,
            headerVisible: false,
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: ''},
            rowHeight: 58,
            daysOfWeekHeight: 32,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: true,
              cellMargin: EdgeInsets.all(3),
              markersMaxCount: 2,
              markerSize: 5,
              markerMargin: EdgeInsets.symmetric(horizontal: 1.5),
            ),
            calendarBuilders: CalendarBuilders<Schedule>(
              dowBuilder: (context, day) {
                final label = _weekdayKr[day.weekday % 7];
                return Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
              defaultBuilder: (context, day, _) =>
                  _DayCell(day: day, textColor: AppColors.textPrimary),
              outsideBuilder: (context, day, _) =>
                  _DayCell(day: day, textColor: AppColors.textMuted),
              todayBuilder: (context, day, _) => _DayCell(
                day: day,
                textColor: Colors.white,
                highlightColor: AppColors.progressTeal,
              ),
              selectedBuilder: (context, day, _) => _DayCell(
                day: day,
                textColor: AppColors.progressTeal,
                // ignore: deprecated_member_use
                highlightColor: AppColors.progressTeal.withOpacity(0.15),
              ),
              markerBuilder: (context, day, schedules) {
                if (schedules.isEmpty) return null;
                final hasTaken =
                    schedules.any((s) => s.status == ScheduleStatus.taken);
                final hasMissed =
                    schedules.any((s) => s.status == ScheduleStatus.missed);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasTaken) _dot(AppColors.progressTeal),
                      if (hasMissed) _dot(AppColors.alertPrimary),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 5,
        height: 5,
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  void _goPrev() {
    final prev = DateTime(_focusedDay.year, _focusedDay.month - 1);
    setState(() => _focusedDay = prev);
    ref.read(calendarFocusedMonthProvider.notifier).go(prev);
  }

  void _goNext() {
    final next = DateTime(_focusedDay.year, _focusedDay.month + 1);
    setState(() => _focusedDay = next);
    ref.read(calendarFocusedMonthProvider.notifier).go(next);
  }
}

// ── 날짜 셀 ────────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.textColor,
    this.highlightColor,
  });

  final DateTime day;
  final Color textColor;
  final Color? highlightColor;

  static const _weekdayKr = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: highlightColor != null
              ? BoxDecoration(color: highlightColor, shape: BoxShape.circle)
              : null,
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          _weekdayKr[day.weekday % 7],
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── 달력 헤더 ──────────────────────────────────────────────────────────────────

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.focusedMonth,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime focusedMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
      child: Row(
        children: [
          Text(
            AppFormat.yearMonthKorean(focusedMonth),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          _NavButton(icon: Icons.chevron_left_rounded, onTap: onPrev),
          const SizedBox(width: AppDimensions.paddingXs),
          _NavButton(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }
}
