import 'choice_generation_mode.dart';

/// `PATCH /members/me/settings/choice-generation-mode` 요청.
class ChoiceModeRequest {
  const ChoiceModeRequest(this.mode);

  final ChoiceGenerationMode mode;

  Map<String, dynamic> toJson() => {'choiceGenerationMode': mode.serverValue};
}
