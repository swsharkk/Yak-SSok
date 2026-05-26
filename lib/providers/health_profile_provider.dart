import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/health_profile.dart';

part 'health_profile_provider.g.dart';

const _kHealthProfileKey = 'health_profile';

@riverpod
class HealthProfileController extends _$HealthProfileController {
  @override
  Future<HealthProfile> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kHealthProfileKey);
    if (raw == null) return const HealthProfile();
    return HealthProfile.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> save(HealthProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kHealthProfileKey, jsonEncode(profile.toJson()));
    state = AsyncData(profile);
  }
}
