import '../models/drug_interaction.dart';

abstract class InteractionRepository {
  /// 약 이름 목록에서 위험 조합 검색.
  Future<List<DrugInteraction>> checkInteractions(List<String> medicineNames);
}
