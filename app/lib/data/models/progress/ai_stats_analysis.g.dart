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
  periodLabel: json['periodLabel'] as String? ?? '',
  forecast: json['forecast'] == null
      ? null
      : AiExamForecast.fromJson(json['forecast'] as Map<String, dynamic>),
  forecastHint: json['forecastHint'] as String?,
  repeatedWrong: json['repeatedWrong'] == null
      ? null
      : AiRepeatedWrong.fromJson(json['repeatedWrong'] as Map<String, dynamic>),
  readiness: json['readiness'] == null
      ? null
      : AiAnalysisReadiness.fromJson(json['readiness'] as Map<String, dynamic>),
  nextGoal: json['nextGoal'] as String?,
);

Map<String, dynamic> _$$AiStatsAnalysisImplToJson(
  _$AiStatsAnalysisImpl instance,
) => <String, dynamic>{
  'headline': instance.headline,
  'findings': instance.findings,
  'trend': instance.trend,
  'strength': instance.strength,
  'actions': instance.actions,
  'periodLabel': instance.periodLabel,
  'forecast': instance.forecast,
  'forecastHint': instance.forecastHint,
  'repeatedWrong': instance.repeatedWrong,
  'readiness': instance.readiness,
  'nextGoal': instance.nextGoal,
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
  conceptTopicUuid: json['conceptTopicUuid'] as String?,
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
  'conceptTopicUuid': instance.conceptTopicUuid,
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
  AiAnalysisActionType.randomPractice: 'RANDOM_PRACTICE',
  AiAnalysisActionType.practiceLatestTrend: 'PRACTICE_LATEST_TREND',
  AiAnalysisActionType.unknown: 'unknown',
};

_$AiExamForecastImpl _$$AiExamForecastImplFromJson(Map<String, dynamic> json) =>
    _$AiExamForecastImpl(
      expectedScore: (json['expectedScore'] as num?)?.toInt() ?? 0,
      subjectOneExpectedCount:
          (json['subjectOneExpectedCount'] as num?)?.toInt() ?? 0,
      subjectOneQuestionCount:
          (json['subjectOneQuestionCount'] as num?)?.toInt() ?? 0,
      isSubjectOneFailRisk: json['isSubjectOneFailRisk'] as bool? ?? false,
      subjectTwoExpectedCount:
          (json['subjectTwoExpectedCount'] as num?)?.toInt() ?? 0,
      subjectTwoQuestionCount:
          (json['subjectTwoQuestionCount'] as num?)?.toInt() ?? 0,
      isSubjectTwoFailRisk: json['isSubjectTwoFailRisk'] as bool? ?? false,
      verdict:
          $enumDecodeNullable(
            _$AiForecastVerdictEnumMap,
            json['verdict'],
            unknownValue: AiForecastVerdict.unknown,
          ) ??
          AiForecastVerdict.unknown,
      verdictLabel: json['verdictLabel'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
    );

Map<String, dynamic> _$$AiExamForecastImplToJson(
  _$AiExamForecastImpl instance,
) => <String, dynamic>{
  'expectedScore': instance.expectedScore,
  'subjectOneExpectedCount': instance.subjectOneExpectedCount,
  'subjectOneQuestionCount': instance.subjectOneQuestionCount,
  'isSubjectOneFailRisk': instance.isSubjectOneFailRisk,
  'subjectTwoExpectedCount': instance.subjectTwoExpectedCount,
  'subjectTwoQuestionCount': instance.subjectTwoQuestionCount,
  'isSubjectTwoFailRisk': instance.isSubjectTwoFailRisk,
  'verdict': _$AiForecastVerdictEnumMap[instance.verdict]!,
  'verdictLabel': instance.verdictLabel,
  'summary': instance.summary,
  'detail': instance.detail,
};

const _$AiForecastVerdictEnumMap = {
  AiForecastVerdict.subjectFailRisk: 'SUBJECT_FAIL_RISK',
  AiForecastVerdict.passLikely: 'PASS_LIKELY',
  AiForecastVerdict.borderline: 'BORDERLINE',
  AiForecastVerdict.belowPass: 'BELOW_PASS',
  AiForecastVerdict.unknown: 'unknown',
};

_$AiRepeatedWrongImpl _$$AiRepeatedWrongImplFromJson(
  Map<String, dynamic> json,
) => _$AiRepeatedWrongImpl(
  questionCount: (json['questionCount'] as num?)?.toInt() ?? 0,
  unresolvedCount: (json['unresolvedCount'] as num?)?.toInt() ?? 0,
  text: json['text'] as String? ?? '',
);

Map<String, dynamic> _$$AiRepeatedWrongImplToJson(
  _$AiRepeatedWrongImpl instance,
) => <String, dynamic>{
  'questionCount': instance.questionCount,
  'unresolvedCount': instance.unresolvedCount,
  'text': instance.text,
};

_$AiAnalysisReadinessImpl _$$AiAnalysisReadinessImplFromJson(
  Map<String, dynamic> json,
) => _$AiAnalysisReadinessImpl(
  message: json['message'] as String? ?? '',
  topicName: json['topicName'] as String?,
  solvedCount: (json['solvedCount'] as num?)?.toInt() ?? 0,
  targetCount: (json['targetCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$AiAnalysisReadinessImplToJson(
  _$AiAnalysisReadinessImpl instance,
) => <String, dynamic>{
  'message': instance.message,
  'topicName': instance.topicName,
  'solvedCount': instance.solvedCount,
  'targetCount': instance.targetCount,
};
