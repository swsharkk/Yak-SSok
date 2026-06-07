// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todaySchedulesHash() => r'cca2643ed7065ff1e29fc3b4976b1e3b54a5eb01';

/// 오늘의 복약 일정.
///
/// Copied from [TodaySchedules].
@ProviderFor(TodaySchedules)
final todaySchedulesProvider =
    AutoDisposeAsyncNotifierProvider<TodaySchedules, List<Schedule>>.internal(
  TodaySchedules.new,
  name: r'todaySchedulesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todaySchedulesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TodaySchedules = AutoDisposeAsyncNotifier<List<Schedule>>;
String _$todayProgressHash() => r'91ab031954f4f6b7b7e8ae2fbae8c11797915474';

/// 오늘의 진행 상황(예: 2/5).
///
/// Copied from [TodayProgress].
@ProviderFor(TodayProgress)
final todayProgressProvider = AutoDisposeAsyncNotifierProvider<TodayProgress,
    ({int taken, int total})>.internal(
  TodayProgress.new,
  name: r'todayProgressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayProgressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TodayProgress = AutoDisposeAsyncNotifier<({int taken, int total})>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
