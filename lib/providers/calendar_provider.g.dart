// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarMonthEventsHash() =>
    r'68da8606636f50bb47fde9ea62f297067cb34143';

/// 포커스된 월의 이벤트 맵. 달력 마커 표시용.
///
/// Copied from [calendarMonthEvents].
@ProviderFor(calendarMonthEvents)
final calendarMonthEventsProvider =
    AutoDisposeFutureProvider<Map<DateTime, List<Schedule>>>.internal(
  calendarMonthEvents,
  name: r'calendarMonthEventsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarMonthEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CalendarMonthEventsRef
    = AutoDisposeFutureProviderRef<Map<DateTime, List<Schedule>>>;
String _$calendarStatsHash() => r'ad91cafb2c198c53f59a82a9080e5d60645de04f';

/// 포커스된 월의 복용 통계 (복용률, 연속 복용일).
///
/// Copied from [calendarStats].
@ProviderFor(calendarStats)
final calendarStatsProvider = AutoDisposeFutureProvider<
    ({double complianceRate, int streakDays})>.internal(
  calendarStats,
  name: r'calendarStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CalendarStatsRef
    = AutoDisposeFutureProviderRef<({double complianceRate, int streakDays})>;
String _$calendarSelectedDateHash() =>
    r'd8025d8e613c68231f8f88a6f995f067f922d8f3';

/// 달력에서 선택된 날짜 (자정 기준).
///
/// Copied from [CalendarSelectedDate].
@ProviderFor(CalendarSelectedDate)
final calendarSelectedDateProvider =
    AutoDisposeNotifierProvider<CalendarSelectedDate, DateTime>.internal(
  CalendarSelectedDate.new,
  name: r'calendarSelectedDateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarSelectedDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CalendarSelectedDate = AutoDisposeNotifier<DateTime>;
String _$calendarFocusedMonthHash() =>
    r'e54d1997451ffcf4133d7fda25f1a9a35834f641';

/// 달력에서 현재 보이는 월 (1일 기준).
///
/// Copied from [CalendarFocusedMonth].
@ProviderFor(CalendarFocusedMonth)
final calendarFocusedMonthProvider =
    AutoDisposeNotifierProvider<CalendarFocusedMonth, DateTime>.internal(
  CalendarFocusedMonth.new,
  name: r'calendarFocusedMonthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarFocusedMonthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CalendarFocusedMonth = AutoDisposeNotifier<DateTime>;
String _$calendarDaySchedulesHash() =>
    r'173051e7d68e545e4f19d6a0617a535c7bb40825';

/// 선택된 날짜의 일정. 복용 완료 처리 가능.
///
/// Copied from [CalendarDaySchedules].
@ProviderFor(CalendarDaySchedules)
final calendarDaySchedulesProvider = AutoDisposeAsyncNotifierProvider<
    CalendarDaySchedules, List<Schedule>>.internal(
  CalendarDaySchedules.new,
  name: r'calendarDaySchedulesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarDaySchedulesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CalendarDaySchedules = AutoDisposeAsyncNotifier<List<Schedule>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
