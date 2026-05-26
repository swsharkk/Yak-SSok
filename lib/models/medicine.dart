import 'package:freezed_annotation/freezed_annotation.dart';

part 'medicine.freezed.dart';
part 'medicine.g.dart';

/// 약 정보. 식약처 API 응답 + 사용자 등록 약을 모두 담는다.
@freezed
class Medicine with _$Medicine {
  const factory Medicine({
    required String id,
    required String name,
    String? imageUrl,
    String? company,
    String? dosage, // 예: "500mg"
    String? description,
    String? cautions,
  }) = _Medicine;

  factory Medicine.fromJson(Map<String, dynamic> json) =>
      _$MedicineFromJson(json);
}
