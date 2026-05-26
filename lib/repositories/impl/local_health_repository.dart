import '../../models/health_summary.dart';
import '../health_repository.dart';

class LocalHealthRepository implements HealthRepository {
  @override
  Future<HealthSummary> getTodaySummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const HealthSummary(hydrationLiters: 1.2, steps: 3402);
  }
}
