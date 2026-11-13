// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explanation_outline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExplanationOutlineImpl _$$ExplanationOutlineImplFromJson(
  Map<String, dynamic> json,
) => _$ExplanationOutlineImpl(
  choiceCount: (json['choiceCount'] as num?)?.toInt() ?? 0,
  sections:
      (json['sections'] as List<dynamic>?)
          ?.map(
            (e) =>
                ExplanationOutlineSection.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ExplanationOutlineImplToJson(
  _$ExplanationOutlineImpl instance,
) => <String, dynamic>{
  'choiceCount': instance.choiceCount,
  'sections': instance.sections,
};

_$ExplanationOutlineSectionImpl _$$ExplanationOutlineSectionImplFromJson(
  Map<String, dynamic> json,
) => _$ExplanationOutlineSectionImpl(
  kind:
      $enumDecodeNullable(
        _$ExplanationOutlineSectionKindEnumMap,
        json['kind'],
        unknownValue: ExplanationOutlineSectionKind.unknown,
      ) ??
      ExplanationOutlineSectionKind.unknown,
  itemCharacterCounts:
      (json['itemCharacterCounts'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ExplanationOutlineSectionImplToJson(
  _$ExplanationOutlineSectionImpl instance,
) => <String, dynamic>{
  'kind': _$ExplanationOutlineSectionKindEnumMap[instance.kind]!,
  'itemCharacterCounts': instance.itemCharacterCounts,
};

const _$ExplanationOutlineSectionKindEnumMap = {
  ExplanationOutlineSectionKind.correctReason: 'CORRECT_REASON',
  ExplanationOutlineSectionKind.examTip: 'EXAM_TIP',
  ExplanationOutlineSectionKind.keyConcepts: 'KEY_CONCEPTS',
  ExplanationOutlineSectionKind.confusingPoints: 'CONFUSING_POINTS',
  ExplanationOutlineSectionKind.choiceAnalyses: 'CHOICE_ANALYSES',
  ExplanationOutlineSectionKind.unknown: 'unknown',
};
