import 'package:dio/dio.dart';

import '../core/constants.dart';
import '../models/medicine.dart';

/// 식약처 공공데이터 API 클라이언트.
/// UI나 provider에서 직접 호출하지 말고 [MedicineRepository]를 경유한다.
class MedicineService {
  MedicineService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.moefBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  final Dio _dio;

  /// 약 검색. 백엔드 미정 단계에서는 호출하지 않아도 됨.
  Future<List<Medicine>> searchByName(String name) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/getDrbEasyDrugList',
      queryParameters: {
        'serviceKey': AppConstants.moefApiKey,
        'itemName': name,
        'type': 'json',
        'numOfRows': 20,
        'pageNo': 1,
      },
    );

    final body = res.data ?? const {};
    final items = (((body['body'] as Map?)?['items']) as List?) ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(_mapItem)
        .toList(growable: false);
  }

  Medicine _mapItem(Map<String, dynamic> json) {
    return Medicine(
      id: (json['itemSeq'] ?? '').toString(),
      name: (json['itemName'] ?? '').toString(),
      company: json['entpName']?.toString(),
      imageUrl: json['itemImage']?.toString(),
      description: json['efcyQesitm']?.toString(),
      cautions: json['atpnQesitm']?.toString(),
    );
  }
}
