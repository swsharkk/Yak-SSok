// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hydration_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hydrationControllerHash() =>
    r'cc4b015725aa537002a14b008b20a631ba099f11';

/// 오늘의 수분 섭취량(mL)을 SharedPreferences에 저장/불러오는 컨트롤러.
/// 날짜가 바뀌면 자동으로 0 으로 리셋된다.
///
/// Copied from [HydrationController].
@ProviderFor(HydrationController)
final hydrationControllerProvider =
    AutoDisposeAsyncNotifierProvider<HydrationController, int>.internal(
  HydrationController.new,
  name: r'hydrationControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hydrationControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HydrationController = AutoDisposeAsyncNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
