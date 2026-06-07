import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../models/drug_interaction.dart';
import '../../repositories/interaction_repository.dart';
import '../../services/backend_auth_service.dart';

class BackendInteractionRepository implements InteractionRepository {
  Dio get _dio => Dio(BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 15),
      ));

  @override
  Future<List<DrugInteraction>> checkInteractions(
      List<String> medicineNames) async {
    if (medicineNames.isEmpty) return [];

    final uid = await BackendAuthService.currentUid();
    final options = await BackendAuthService.authOptions();
    if (uid == null || options == null) return [];

    // 새로 추가되는 약 이름 (리스트의 첫 번째)
    final newMedName = medicineNames.first;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/medication/verify-dur/$uid',
        queryParameters: {'new_med_name': newMedName},
        options: options,
      );

      final data = response.data ?? {};
      if (data['interact'] != true) return [];

      return [
        DrugInteraction(
          id: 'dur_${DateTime.now().millisecondsSinceEpoch}',
          drugAName: newMedName,
          drugBName: '현재 복용 중인 약',
          severity: InteractionSeverity.high,
          description: data['message']?.toString() ?? '병용금기 위험이 있습니다.',
        ),
      ];
    } on DioException {
      return [];
    }
  }
}
