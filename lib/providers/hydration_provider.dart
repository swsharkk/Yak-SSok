import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'hydration_provider.g.dart';

const _kIntakeKey = 'hydration_intake_ml';
const _kDateKey = 'hydration_date';

/// 오늘의 수분 섭취량(mL)을 SharedPreferences에 저장/불러오는 컨트롤러.
/// 날짜가 바뀌면 자동으로 0 으로 리셋된다.
@riverpod
class HydrationController extends _$HydrationController {
  @override
  Future<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kDateKey);
    final today = _dateKey(DateTime.now());
    if (saved != today) {
      await prefs.setString(_kDateKey, today);
      await prefs.setInt(_kIntakeKey, 0);
      return 0;
    }
    return prefs.getInt(_kIntakeKey) ?? 0;
  }

  Future<void> add(int ml) async {
    final current = await future;
    final updated = current + ml;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kIntakeKey, updated);
    state = AsyncData(updated);
  }
}

String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
