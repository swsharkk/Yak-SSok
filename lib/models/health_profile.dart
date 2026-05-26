import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_profile.freezed.dart';
part 'health_profile.g.dart';

@freezed
class HealthProfile with _$HealthProfile {
  const factory HealthProfile({
    @Default(170.0) double heightCm,
    @Default(65.0) double weightKg,
    @Default(30) int age,
    @Default('male') String gender,
    @Default(2000) int dailyWaterGoalMl,
  }) = _HealthProfile;

  factory HealthProfile.fromJson(Map<String, dynamic> json) =>
      _$HealthProfileFromJson(json);
}
