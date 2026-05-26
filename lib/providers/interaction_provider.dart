import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/drug_interaction.dart';
import 'repository_providers.dart';

part 'interaction_provider.g.dart';

/// 사용자 등록 약 목록의 상호작용 위험 조합 반환.
@riverpod
Future<List<DrugInteraction>> drugInteractions(
  DrugInteractionsRef ref,
  List<String> medicineNames,
) async {
  return ref
      .read(interactionRepositoryProvider)
      .checkInteractions(medicineNames);
}
