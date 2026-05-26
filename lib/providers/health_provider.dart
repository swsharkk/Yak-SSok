import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/health_profile.dart';
import '../models/health_summary.dart';
import 'health_profile_provider.dart';
import 'hydration_provider.dart';
import 'repository_providers.dart';

part 'health_provider.g.dart';

@riverpod
Future<HealthSummary> todayHealthSummary(TodayHealthSummaryRef ref) async {
  final summary = await ref.watch(healthRepositoryProvider).getTodaySummary();
  final profile = await ref.watch(healthProfileControllerProvider.future);
  final hydrationMl = await ref.watch(hydrationControllerProvider.future);

  return summary.copyWith(
    hydrationLiters: hydrationMl / 1000.0,
    calories: _calcCalories(summary.steps, profile),
    waterGoalMl: profile.dailyWaterGoalMl,
  );
}

int _calcCalories(int steps, HealthProfile profile) {
  // stride length (m) = height × 0.414 (남) / 0.413 (여)
  // distance (km) = steps × stride / 1000
  // kcal = weight × distance × 1.036
  final strideM =
      profile.heightCm * 0.01 * (profile.gender == 'male' ? 0.414 : 0.413);
  final distanceKm = steps * strideM / 1000;
  return (profile.weightKg * distanceKm * 1.036).round();
}
