import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'guardian_provider.g.dart';

const _kGuardianKey = 'guardian_phone';

@Riverpod(keepAlive: true)
class GuardianController extends _$GuardianController {
  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kGuardianKey);
  }

  Future<void> save(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kGuardianKey, number);
    state = AsyncData(number);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kGuardianKey);
    state = const AsyncData(null);
  }
}
