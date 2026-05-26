import '../models/health_summary.dart';

/// 건강 요약(수분/걸음) Repository.
/// 추후 헬스킷/구글핏 또는 자체 백엔드 연동.
abstract class HealthRepository {
  Future<HealthSummary> getTodaySummary();
}
