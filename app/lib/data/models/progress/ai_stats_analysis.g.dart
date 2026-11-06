// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_stats_analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiStatsAnalysisImpl _$$AiStatsAnalysisImplFromJson(
  Map<String, dynamic> json,
) => _$AiStatsAnalysisImpl(
  headline: json['headline'] as String? ?? '',
  findings:
      (json['findings'] as List<dynamic>?)
          ?.map((e) => AiAnalysisFinding.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  trend: json['trend'] as String?,
  strength: json['strength'] == null
      ? null
      : AiAnalysisStrength.fromJson(json['strength'] as Map<String, dynamic>),
  actions:
      (json['actions'] as List<dynamic>?)
          ?.map((e) => AiAnalysisAction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$AiStatsAnalysisImplToJson(
  _$AiStatsAnalysisImpl instance,
) => <String, dynamic>{
  'headline': instance.headline,
  'findings': instance.findings,
  'trend': instance.trend,
  'strength': instance.strength,
  'actions': instance.actions,
};

_$AiAnalysisFindingImpl _$$AiAnalysisFindingImplFromJson(
  Map<String, dynamic> json,
) => _$AiAnalysisFindingImpl(
  topicUuid: json['topicUuid'] as String? ?? '',
  topicName: json['topicName'] as String? ?? '',
  kind:
      $enumDecodeNullable(
        _$AiFindingKindEnumMap,
        json['kind'],
        unknownValue: AiFindingKind.unknown,
      ) ??
      AiFindingKind.unknown,
  solvedCount: (json['solvedCount'] as num?)?.toInt() ?? 0,
  correctRatePercent: (json['correctRatePercent'] as num?)?.toInt() ?? 0,
  evidence: json['evidence'] as String? ?? '',
  insight: json['insight'] as String?,
);

Map<String, dynamic> _$$AiAnalysisFindingImplToJson(
  _$AiAnalysisFindingImpl instance,
) => <String, dynamic>{
  'topicUuid': instance.topicUuid,
  'topicName': instance.topicName,
  'kind': _$AiFindingKindEnumMap[instance.kind]!,
  'solvedCount': instance.solvedCount,
  'correctRatePercent': instance.correctRatePercent,
  'evidence': instance.evidence,
  'insight': instance.insight,
};

const _$AiFindingKindEnumMap = {
  AiFindingKind.weak: 'WEAK',
  AiFindingKind.shaky: 'SHAKY',
  AiFindingKind.untried: 'UNTRIED',
  AiFindingKind.unknown: 'unknown',
};

_$AiAnalysisStrengthImpl _$$AiAnalysisStrengthImplFromJson(
  Map<String, dynamic> json,
) => _$AiAnalysisStrengthImpl(
  topicUuid: json['topicUuid'] as String? ?? '',
  topicName: json['topicName'] as String? ?? '',
  correctRatePercent: (json['correctRatePercent'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$AiAnalysisStrengthImplToJson(
  _$AiAnalysisStrengthImpl instance,
) => <String, dynamic>{
  'topicUuid': instance.topicUuid,
  'topicName': instance.topicName,
  'correctRatePercent': instance.correctRatePercent,
};

_$AiAnalysisActionImpl _$$AiAnalysisActionImplFromJson(
  Map<String, dynamic> json,
) => _$AiAnalysisActionImpl(
  type:
      $enumDecodeNullable(
        _$AiAnalysisActionTypeEnumMap,
        json['type'],
        unknownValue: AiAnalysisActionType.unknown,
      ) ??
      AiAnalysisActionType.unknown,
  topicUuid: json['topicUuid'] as String?,
  topicName: json['topicName'] as String?,
  count: (json['count'] as num?)?.toInt() ?? 0,
  label: json['label'] as String? ?? '',
);

Map<String, dynamic> _$$AiAnalysisActionImplToJson(
  _$AiAnalysisActionImpl instance,
) => <String, dynamic>{
  'type': _$AiAnalysisActionTypeEnumMap[instance.type]!,
  'topicUuid': instance.topicUuid,
  'topicName': instance.topicName,
  'count': instance.count,
  'label': instance.label,
};

const _$AiAnalysisActionTypeEnumMap = {
  AiAnalysisActionType.practiceTopic: 'PRACTICE_TOPIC',
  AiAnalysisActionType.reviewWrong: 'REVIEW_WRONG',
  AiAnalysisActionType.unknown: 'unknown',
};
