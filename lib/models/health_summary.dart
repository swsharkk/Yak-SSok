import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_summary.freezed.dart';
part 'health_summary.g.dart';

/// 홈 화면 하단의 건강 요약(수분, 걸음, 칼로리 등).
@freezed
class HealthSummary with _$HealthSummary {
  const factory HealthSummary({
    required double hydrationLiters,
    required int steps,
    int? calories,
    int? waterGoalMl,
  }) = _HealthSummary;

  factory HealthSummary.fromJson(Map<String, dynamic> json) =>
      _$HealthSummaryFromJson(json);
}
