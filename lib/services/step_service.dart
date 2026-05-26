import 'package:health/health.dart';

/// Apple Health / Google Health Connect에서 오늘의 걸음수를 읽어온다.
/// 권한 거부 또는 플랫폼 미지원 시 0을 반환한다.
class StepService {
  final Health _health = Health();
  bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  Future<int> getTodaySteps() async {
    try {
      await _ensureConfigured();
      final granted = await _health.requestAuthorization(
        [HealthDataType.STEPS],
        permissions: [HealthDataAccess.READ],
      );
      if (!granted) return 0;
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      return await _health.getTotalStepsInInterval(midnight, now) ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
