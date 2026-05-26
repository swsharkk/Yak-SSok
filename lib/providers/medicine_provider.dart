import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/medicine.dart';
import 'repository_providers.dart';

part 'medicine_provider.g.dart';

/// 사용자가 등록한 약 목록.
@riverpod
Future<List<Medicine>> myMedicines(MyMedicinesRef ref) {
  return ref.watch(medicineRepositoryProvider).getMyMedicines();
}

/// 약 검색 (drug_interactions 테이블 기반).
@riverpod
class MedicineSearch extends _$MedicineSearch {
  @override
  AsyncValue<List<Medicine>> build() => const AsyncValue.data([]);

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => ref.read(medicineRepositoryProvider).search(query));
  }
}
