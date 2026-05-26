import '../../models/drug_interaction.dart';
import '../interaction_repository.dart';

class LocalInteractionRepository implements InteractionRepository {
  @override
  Future<List<DrugInteraction>> checkInteractions(
      List<String> medicineNames) async {
    return const [];
  }
}
