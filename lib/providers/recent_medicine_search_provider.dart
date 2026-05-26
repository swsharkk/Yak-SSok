import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/medicine.dart';

final recentMedicineSearchProvider = StateNotifierProvider<
    RecentMedicineSearchController, AsyncValue<List<RecentMedicineSearch>>>(
  (ref) {
    return RecentMedicineSearchController()..load();
  },
);

class RecentMedicineSearch {
  const RecentMedicineSearch({
    required this.medicine,
    required this.searchedAt,
  });

  final Medicine medicine;
  final DateTime searchedAt;

  factory RecentMedicineSearch.fromJson(Map<String, dynamic> json) {
    return RecentMedicineSearch(
      medicine: Medicine.fromJson(json['medicine'] as Map<String, dynamic>),
      searchedAt: DateTime.parse(json['searchedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'medicine': medicine.toJson(),
        'searchedAt': searchedAt.toIso8601String(),
      };
}

class RecentMedicineSearchController
    extends StateNotifier<AsyncValue<List<RecentMedicineSearch>>> {
  RecentMedicineSearchController() : super(const AsyncValue.loading());

  static const _storageKey = 'recent_medicine_searches';
  static const _maxItems = 10;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = await SharedPreferences.getInstance();
      final rawItems = prefs.getStringList(_storageKey) ?? const [];

      return rawItems
          .map((raw) => RecentMedicineSearch.fromJson(
                jsonDecode(raw) as Map<String, dynamic>,
              ))
          .toList(growable: false);
    });
  }

  Future<void> add(Medicine medicine) async {
    final current = state.valueOrNull ?? const <RecentMedicineSearch>[];
    final next = [
      RecentMedicineSearch(
        medicine: medicine,
        searchedAt: DateTime.now(),
      ),
      ...current.where((item) => item.medicine.id != medicine.id),
    ].take(_maxItems).toList(growable: false);

    state = AsyncValue.data(next);
    await _save(next);
  }

  Future<void> clear() async {
    state = const AsyncValue.data([]);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _save(List<RecentMedicineSearch> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      items.map((item) => jsonEncode(item.toJson())).toList(growable: false),
    );
  }
}
