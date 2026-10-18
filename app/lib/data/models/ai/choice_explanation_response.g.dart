// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'choice_explanation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChoiceExplanationResponseImpl _$$ChoiceExplanationResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ChoiceExplanationResponseImpl(
  choiceSetUuid: json['choiceSetUuid'] as String? ?? '',
  selectedChoiceKey: json['selectedChoiceKey'] as String? ?? '',
  status:
      $enumDecodeNullable(
        _$ChoiceExplanationStatusEnumMap,
        json['status'],
        unknownValue: ChoiceExplanationStatus.failed,
      ) ??
      ChoiceExplanationStatus.failed,
  explanation: json['explanation'] == null
      ? null
      : ChoiceExplanation.fromJson(json['explanation'] as Map<String, dynamic>),
  text: json['text'] as String?,
  retryAfterMilliseconds: (json['retryAfterMilliseconds'] as num?)?.toInt(),
  promptVersion: (json['promptVersion'] as num?)?.toInt(),
);

Map<String, dynamic> _$$ChoiceExplanationResponseImplToJson(
  _$ChoiceExplanationResponseImpl instance,
) => <String, dynamic>{
  'choiceSetUuid': instance.choiceSetUuid,
  'selectedChoiceKey': instance.selectedChoiceKey,
  'status': _$ChoiceExplanationStatusEnumMap[instance.status]!,
  'explanation': instance.explanation,
  'text': instance.text,
  'retryAfterMilliseconds': instance.retryAfterMilliseconds,
  'promptVersion': instance.promptVersion,
};

const _$ChoiceExplanationStatusEnumMap = {
  ChoiceExplanationStatus.ready: 'READY',
  ChoiceExplanationStatus.generating: 'GENERATING',
  ChoiceExplanationStatus.failed: 'FAILED',
};
