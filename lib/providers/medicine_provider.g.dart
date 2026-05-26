// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myMedicinesHash() => r'fd73527b556a50a9262cb8844b9cfd4b3df33d84';

/// 사용자가 등록한 약 목록.
///
/// Copied from [myMedicines].
@ProviderFor(myMedicines)
final myMedicinesProvider = AutoDisposeFutureProvider<List<Medicine>>.internal(
  myMedicines,
  name: r'myMedicinesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myMedicinesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyMedicinesRef = AutoDisposeFutureProviderRef<List<Medicine>>;
String _$medicineSearchHash() => r'fd419d197277e6611bdc9b86b54be65fc2793b11';

/// 약 검색.
///
/// Copied from [MedicineSearch].
@ProviderFor(MedicineSearch)
final medicineSearchProvider = AutoDisposeNotifierProvider<MedicineSearch,
    AsyncValue<List<Medicine>>>.internal(
  MedicineSearch.new,
  name: r'medicineSearchProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$medicineSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MedicineSearch = AutoDisposeNotifier<AsyncValue<List<Medicine>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
