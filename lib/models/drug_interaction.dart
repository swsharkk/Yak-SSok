import 'package:freezed_annotation/freezed_annotation.dart';

part 'drug_interaction.freezed.dart';
part 'drug_interaction.g.dart';

enum InteractionSeverity { high, medium, low }

@freezed
class DrugInteraction with _$DrugInteraction {
  const factory DrugInteraction({
    required String id,
    required String drugAName,
    required String drugBName,
    required InteractionSeverity severity,
    required String description,
  }) = _DrugInteraction;

  factory DrugInteraction.fromJson(Map<String, dynamic> json) =>
      _$DrugInteractionFromJson(json);
}
