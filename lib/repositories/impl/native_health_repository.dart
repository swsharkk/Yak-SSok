import '../../models/health_summary.dart';
import '../../services/step_service.dart';
import '../health_repository.dart';

/// Apple Health / Google Health Connect에서 건강 데이터를 읽는 구현체.
class NativeHealthRepository implements HealthRepository {
  NativeHealthRepository() : _stepService = StepService();

  final StepService _stepService;

  @override
  Future<HealthSummary> getTodaySummary() async {
    final steps = await _stepService.getTodaySteps();
    return HealthSummary(
      hydrationLiters: 0.0,
      steps: steps,
    );
  }
}
