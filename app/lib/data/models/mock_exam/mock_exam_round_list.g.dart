// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_exam_round_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MockExamRoundListResponseImpl _$$MockExamRoundListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamRoundListResponseImpl(
  examRule: MockExamRule.fromJson(json['examRule'] as Map<String, dynamic>),
  inProgressAttempt: json['inProgressAttempt'] == null
      ? null
      : MockExamInProgressAttempt.fromJson(
          json['inProgressAttempt'] as Map<String, dynamic>,
        ),
  rounds:
      (json['rounds'] as List<dynamic>?)
          ?.map((e) => MockExamRoundSummary.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$MockExamRoundListResponseImplToJson(
  _$MockExamRoundListResponseImpl instance,
) => <String, dynamic>{
  'examRule': instance.examRule,
  'inProgressAttempt': instance.inProgressAttempt,
  'rounds': instance.rounds,
};

_$MockExamRuleImpl _$$MockExamRuleImplFromJson(Map<String, dynamic> json) =>
    _$MockExamRuleImpl(
      questionCount: (json['questionCount'] as num).toInt(),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      maxScore: (json['maxScore'] as num).toInt(),
      passScore: (json['passScore'] as num).toInt(),
      pointsPerQuestion: (json['pointsPerQuestion'] as num).toInt(),
      subjects:
          (json['subjects'] as List<dynamic>?)
              ?.map(
                (e) => MockExamSubjectRule.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$MockExamRuleImplToJson(_$MockExamRuleImpl instance) =>
    <String, dynamic>{
      'questionCount': instance.questionCount,
      'durationMinutes': instance.durationMinutes,
      'maxScore': instance.maxScore,
      'passScore': instance.passScore,
      'pointsPerQuestion': instance.pointsPerQuestion,
      'subjects': instance.subjects,
    };

_$MockExamSubjectRuleImpl _$$MockExamSubjectRuleImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamSubjectRuleImpl(
  subject: $enumDecode(
    _$MockExamSubjectEnumMap,
    json['subject'],
    unknownValue: MockExamSubject.unknown,
  ),
  name: json['name'] as String,
  questionCount: (json['questionCount'] as num).toInt(),
  maxScore: (json['maxScore'] as num).toInt(),
  failBelowScore: (json['failBelowScore'] as num).toInt(),
);

Map<String, dynamic> _$$MockExamSubjectRuleImplToJson(
  _$MockExamSubjectRuleImpl instance,
) => <String, dynamic>{
  'subject': _$MockExamSubjectEnumMap[instance.subject]!,
  'name': instance.name,
  'questionCount': instance.questionCount,
  'maxScore': instance.maxScore,
  'failBelowScore': instance.failBelowScore,
};

const _$MockExamSubjectEnumMap = {
  MockExamSubject.subjectOne: 'SUBJECT_ONE',
  MockExamSubject.subjectTwo: 'SUBJECT_TWO',
  MockExamSubject.unknown: 'unknown',
};

_$MockExamInProgressAttemptImpl _$$MockExamInProgressAttemptImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamInProgressAttemptImpl(
  attemptUuid: json['attemptUuid'] as String,
  roundUuid: json['roundUuid'] as String,
  roundNumber: (json['roundNumber'] as num).toInt(),
  title: json['title'] as String,
  remainingSeconds: (json['remainingSeconds'] as num).toInt(),
  answeredCount: (json['answeredCount'] as num).toInt(),
);

Map<String, dynamic> _$$MockExamInProgressAttemptImplToJson(
  _$MockExamInProgressAttemptImpl instance,
) => <String, dynamic>{
  'attemptUuid': instance.attemptUuid,
  'roundUuid': instance.roundUuid,
  'roundNumber': instance.roundNumber,
  'title': instance.title,
  'remainingSeconds': instance.remainingSeconds,
  'answeredCount': instance.answeredCount,
};

_$MockExamRoundSummaryImpl _$$MockExamRoundSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamRoundSummaryImpl(
  roundUuid: json['roundUuid'] as String,
  roundNumber: (json['roundNumber'] as num).toInt(),
  title: json['title'] as String,
  isFreeTrialRound: json['isFreeTrialRound'] as bool,
  canStart: json['canStart'] as bool,
  startBlockReason: $enumDecodeNullable(
    _$MockExamStartBlockReasonEnumMap,
    json['startBlockReason'],
    unknownValue: MockExamStartBlockReason.unknown,
  ),
  submittedAttemptCount: (json['submittedAttemptCount'] as num).toInt(),
  bestScore: (json['bestScore'] as num?)?.toInt(),
  bestAttemptIsPassed: json['bestAttemptIsPassed'] as bool?,
  bestAttemptFailReason: $enumDecodeNullable(
    _$MockExamFailReasonEnumMap,
    json['bestAttemptFailReason'],
    unknownValue: MockExamFailReason.unknown,
  ),
  lastAttempt: json['lastAttempt'] == null
      ? null
      : MockExamLastAttempt.fromJson(
          json['lastAttempt'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$$MockExamRoundSummaryImplToJson(
  _$MockExamRoundSummaryImpl instance,
) => <String, dynamic>{
  'roundUuid': instance.roundUuid,
  'roundNumber': instance.roundNumber,
  'title': instance.title,
  'isFreeTrialRound': instance.isFreeTrialRound,
  'canStart': instance.canStart,
  'startBlockReason':
      _$MockExamStartBlockReasonEnumMap[instance.startBlockReason],
  'submittedAttemptCount': instance.submittedAttemptCount,
  'bestScore': instance.bestScore,
  'bestAttemptIsPassed': instance.bestAttemptIsPassed,
  'bestAttemptFailReason':
      _$MockExamFailReasonEnumMap[instance.bestAttemptFailReason],
  'lastAttempt': instance.lastAttempt,
};

const _$MockExamStartBlockReasonEnumMap = {
  MockExamStartBlockReason.proRequired: 'PRO_REQUIRED',
  MockExamStartBlockReason.freeTrialUsed: 'FREE_TRIAL_USED',
  MockExamStartBlockReason.otherAttemptInProgress: 'OTHER_ATTEMPT_IN_PROGRESS',
  MockExamStartBlockReason.unknown: 'unknown',
};

const _$MockExamFailReasonEnumMap = {
  MockExamFailReason.none: 'NONE',
  MockExamFailReason.subjectFail: 'SUBJECT_FAIL',
  MockExamFailReason.totalScoreBelow: 'TOTAL_SCORE_BELOW',
  MockExamFailReason.unknown: 'unknown',
};

_$MockExamLastAttemptImpl _$$MockExamLastAttemptImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamLastAttemptImpl(
  attemptUuid: json['attemptUuid'] as String,
  status: $enumDecode(
    _$MockExamAttemptStatusEnumMap,
    json['status'],
    unknownValue: MockExamAttemptStatus.unknown,
  ),
  totalScore: (json['totalScore'] as num?)?.toInt(),
  isPassed: json['isPassed'] as bool?,
  submittedAt: json['submittedAt'] as String?,
);

Map<String, dynamic> _$$MockExamLastAttemptImplToJson(
  _$MockExamLastAttemptImpl instance,
) => <String, dynamic>{
  'attemptUuid': instance.attemptUuid,
  'status': _$MockExamAttemptStatusEnumMap[instance.status]!,
  'totalScore': instance.totalScore,
  'isPassed': instance.isPassed,
  'submittedAt': instance.submittedAt,
};

const _$MockExamAttemptStatusEnumMap = {
  MockExamAttemptStatus.inProgress: 'IN_PROGRESS',
  MockExamAttemptStatus.submitted: 'SUBMITTED',
  MockExamAttemptStatus.unknown: 'unknown',
};
