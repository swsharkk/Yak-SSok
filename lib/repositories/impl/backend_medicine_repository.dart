import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../models/medicine.dart';
import '../../services/backend_auth_service.dart';
import '../../services/medicine_service.dart';
import '../medicine_repository.dart';

class BackendMedicineRepository implements MedicineRepository {
  BackendMedicineRepository({
    Dio? dio,
    MedicineService? medicineService,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.apiBaseUrl,
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 15),
              ),
            ),
        _medicineService = medicineService ?? MedicineService();

  final Dio _dio;
  final MedicineService _medicineService;

  @override
  Future<List<Medicine>> search(String query) async {
    final keyword = query.trim();
    if (keyword.isEmpty) return const [];

    final publicMedicines = await _searchFromPublicApi(keyword);
    if (publicMedicines.isNotEmpty) return publicMedicines;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/medicines/search',
        queryParameters: {
          'query': keyword,
          'limit': 20,
        },
      );
      final data = response.data?['data'];
      if (data is! List) return _searchFromPublicApi(keyword);

      final medicines = data
          .whereType<Map<String, dynamic>>()
          .map(_mapMedicine)
          .where((medicine) => medicine.name.isNotEmpty)
          .toList(growable: false);
      return medicines;
    } catch (_) {
      return const [];
    }
  }

  Future<List<Medicine>> _searchFromPublicApi(String keyword) async {
    if (AppConstants.moefApiKey.isEmpty) return const [];
    try {
      return await _medicineService.searchByName(keyword);
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<Medicine>> getMyMedicines() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/saved-medicines',
      options: await BackendAuthService.authOptions(),
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map((row) {
      return Medicine(
        id: row['id']?.toString() ?? '',
        name: row['medicine_name']?.toString() ?? '',
        company: row['company']?.toString(),
        imageUrl: row['image_url']?.toString(),
        description: row['description']?.toString(),
      );
    }).toList(growable: false);
  }

  @override
  Future<Medicine> register(Medicine medicine) async {
    await _dio.post<Map<String, dynamic>>(
      '/saved-medicines',
      data: {
        'medicineName': medicine.name,
        'company': medicine.company,
        'description': medicine.description,
        'imageUrl': medicine.imageUrl,
        'slot': 'custom',
        'doseCount': 1,
      },
      options: await BackendAuthService.authOptions(),
    );
    return medicine;
  }

  @override
  Future<void> remove(String id) async {
    await _dio.delete(
      '/saved-medicines/$id',
      options: await BackendAuthService.authOptions(),
    );
  }

  Medicine _mapMedicine(Map<String, dynamic> json) {
    String? optional(String key) {
      final value = json[key]?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    return Medicine(
      id: json['id']?.toString() ?? json['itemSeq']?.toString() ?? '',
      name: json['name']?.toString() ?? json['itemName']?.toString() ?? '',
      company: optional('company') ?? optional('entpName'),
      imageUrl: optional('imageUrl') ?? optional('itemImage'),
      dosage: optional('dosage'),
      description: optional('description') ?? optional('efcyQesitm'),
      cautions: optional('cautions') ?? optional('atpnQesitm'),
    );
  }
}
