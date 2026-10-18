// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'choice_explanation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChoiceExplanationImpl _$$ChoiceExplanationImplFromJson(
  Map<String, dynamic> json,
) => _$ChoiceExplanationImpl(
  selectedChoiceKey: json['selectedChoiceKey'] as String? ?? '',
  correctChoiceKey: json['correctChoiceKey'] as String? ?? '',
  isSelectedCorrect: json['isSelectedCorrect'] as bool? ?? false,
  verdict: json['verdict'] as String? ?? '',
  correctReason: json['correctReason'] as String? ?? '',
  keyConcepts:
      (json['keyConcepts'] as List<dynamic>?)
          ?.map((e) => KeyConcept.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  confusingPoints:
      (json['confusingPoints'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  choiceAnalyses:
      (json['choiceAnalyses'] as List<dynamic>?)
          ?.map((e) => ChoiceAnalysis.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  examTip: json['examTip'] as String? ?? '',
);

Map<String, dynamic> _$$ChoiceExplanationImplToJson(
  _$ChoiceExplanationImpl instance,
) => <String, dynamic>{
  'selectedChoiceKey': instance.selectedChoiceKey,
  'correctChoiceKey': instance.correctChoiceKey,
  'isSelectedCorrect': instance.isSelectedCorrect,
  'verdict': instance.verdict,
  'correctReason': instance.correctReason,
  'keyConcepts': instance.keyConcepts,
  'confusingPoints': instance.confusingPoints,
  'choiceAnalyses': instance.choiceAnalyses,
  'examTip': instance.examTip,
};

_$KeyConceptImpl _$$KeyConceptImplFromJson(Map<String, dynamic> json) =>
    _$KeyConceptImpl(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$$KeyConceptImplToJson(_$KeyConceptImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
    };

_$ChoiceAnalysisImpl _$$ChoiceAnalysisImplFromJson(Map<String, dynamic> json) =>
    _$ChoiceAnalysisImpl(
      choiceKey: json['choiceKey'] as String? ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
      reason: json['reason'] as String? ?? '',
    );

Map<String, dynamic> _$$ChoiceAnalysisImplToJson(
  _$ChoiceAnalysisImpl instance,
) => <String, dynamic>{
  'choiceKey': instance.choiceKey,
  'isCorrect': instance.isCorrect,
  'reason': instance.reason,
};
