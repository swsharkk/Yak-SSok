import 'package:freezed_annotation/freezed_annotation.dart';

part 'pharmacy.freezed.dart';
part 'pharmacy.g.dart';

@freezed
class Pharmacy with _$Pharmacy {
  const factory Pharmacy({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    String? address,
    String? phone,
    double? distanceMeters,
    bool? isOpenNow,
  }) = _Pharmacy;

  factory Pharmacy.fromJson(Map<String, dynamic> json) =>
      _$PharmacyFromJson(json);
}
