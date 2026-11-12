// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_exam_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MockExamResultResponseImpl _$$MockExamResultResponseImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamResultResponseImpl(
  attemptUuid: json['attemptUuid'] as String,
  roundUuid: json['roundUuid'] as String,
  roundNumber: (json['roundNumber'] as num).toInt(),
  title: json['title'] as String,
  submitReason: $enumDecode(
    _$MockExamSubmitReasonEnumMap,
    json['submitReason'],
    unknownValue: MockExamSubmitReason.unknown,
  ),
  startedAt: json['startedAt'] as String,
  submittedAt: json['submittedAt'] as String,
  elapsedSeconds: (json['elapsedSeconds'] as num).toInt(),
  totalScore: (json['totalScore'] as num).toInt(),
  maxScore: (json['maxScore'] as num).toInt(),
  passScore: (json['passScore'] as num).toInt(),
  correctCount: (json['correctCount'] as num).toInt(),
  questionCount: (json['questionCount'] as num).toInt(),
  isPassed: json['isPassed'] as bool,
  failReason: $enumDecode(
    _$MockExamFailReasonEnumMap,
    json['failReason'],
    unknownValue: MockExamFailReason.unknown,
  ),
  ranking: json['ranking'] == null
      ? null
      : MockExamRanking.fromJson(json['ranking'] as Map<String, dynamic>),
  subjects:
      (json['subjects'] as List<dynamic>?)
          ?.map(
            (e) => MockExamSubjectResult.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  topics:
      (json['topics'] as List<dynamic>?)
          ?.map((e) => MockExamTopicResult.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  questionMarks:
      (json['questionMarks'] as List<dynamic>?)
          ?.map((e) => MockExamQuestionMark.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  reviews:
      (json['reviews'] as List<dynamic>?)
          ?.map(
            (e) => MockExamQuestionReview.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  nextStep: json['nextStep'] == null
      ? null
      : MockExamNextStep.fromJson(json['nextStep'] as Map<String, dynamic>),
  lockedSections:
      (json['lockedSections'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$MockExamResultResponseImplToJson(
  _$MockExamResultResponseImpl instance,
) => <String, dynamic>{
  'attemptUuid': instance.attemptUuid,
  'roundUuid': instance.roundUuid,
  'roundNumber': instance.roundNumber,
  'title': instance.title,
  'submitReason': _$MockExamSubmitReasonEnumMap[instance.submitReason]!,
  'startedAt': instance.startedAt,
  'submittedAt': instance.submittedAt,
  'elapsedSeconds': instance.elapsedSeconds,
  'totalScore': instance.totalScore,
  'maxScore': instance.maxScore,
  'passScore': instance.passScore,
  'correctCount': instance.correctCount,
  'questionCount': instance.questionCount,
  'isPassed': instance.isPassed,
  'failReason': _$MockExamFailReasonEnumMap[instance.failReason]!,
  'ranking': instance.ranking,
  'subjects': instance.subjects,
  'topics': instance.topics,
  'questionMarks': instance.questionMarks,
  'reviews': instance.reviews,
  'nextStep': instance.nextStep,
  'lockedSections': instance.lockedSections,
};

const _$MockExamSubmitReasonEnumMap = {
  MockExamSubmitReason.member: 'MEMBER',
  MockExamSubmitReason.timeUp: 'TIME_UP',
  MockExamSubmitReason.unknown: 'unknown',
};

const _$MockExamFailReasonEnumMap = {
  MockExamFailReason.none: 'NONE',
  MockExamFailReason.subjectFail: 'SUBJECT_FAIL',
  MockExamFailReason.totalScoreBelow: 'TOTAL_SCORE_BELOW',
  MockExamFailReason.unknown: 'unknown',
};

_$MockExamRankingImpl _$$MockExamRankingImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamRankingImpl(
  rankPosition: (json['rankPosition'] as num).toInt(),
  takerCount: (json['takerCount'] as num).toInt(),
  topPercent: (json['topPercent'] as num).toInt(),
);

Map<String, dynamic> _$$MockExamRankingImplToJson(
  _$MockExamRankingImpl instance,
) => <String, dynamic>{
  'rankPosition': instance.rankPosition,
  'takerCount': instance.takerCount,
  'topPercent': instance.topPercent,
};

_$MockExamSubjectResultImpl _$$MockExamSubjectResultImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamSubjectResultImpl(
  subject: $enumDecode(
    _$MockExamSubjectEnumMap,
    json['subject'],
    unknownValue: MockExamSubject.unknown,
  ),
  name: json['name'] as String,
  correctCount: (json['correctCount'] as num).toInt(),
  questionCount: (json['questionCount'] as num).toInt(),
  score: (json['score'] as num).toInt(),
  maxScore: (json['maxScore'] as num).toInt(),
  failBelowScore: (json['failBelowScore'] as num).toInt(),
  isFailed: json['isFailed'] as bool,
);

Map<String, dynamic> _$$MockExamSubjectResultImplToJson(
  _$MockExamSubjectResultImpl instance,
) => <String, dynamic>{
  'subject': _$MockExamSubjectEnumMap[instance.subject]!,
  'name': instance.name,
  'correctCount': instance.correctCount,
  'questionCount': instance.questionCount,
  'score': instance.score,
  'maxScore': instance.maxScore,
  'failBelowScore': instance.failBelowScore,
  'isFailed': instance.isFailed,
};

const _$MockExamSubjectEnumMap = {
  MockExamSubject.subjectOne: 'SUBJECT_ONE',
  MockExamSubject.subjectTwo: 'SUBJECT_TWO',
  MockExamSubject.unknown: 'unknown',
};

_$MockExamTopicResultImpl _$$MockExamTopicResultImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamTopicResultImpl(
  topicUuid: json['topicUuid'] as String,
  topicName: json['topicName'] as String?,
  subject: $enumDecode(
    _$MockExamSubjectEnumMap,
    json['subject'],
    unknownValue: MockExamSubject.unknown,
  ),
  correctCount: (json['correctCount'] as num).toInt(),
  questionCount: (json['questionCount'] as num).toInt(),
);

Map<String, dynamic> _$$MockExamTopicResultImplToJson(
  _$MockExamTopicResultImpl instance,
) => <String, dynamic>{
  'topicUuid': instance.topicUuid,
  'topicName': instance.topicName,
  'subject': _$MockExamSubjectEnumMap[instance.subject]!,
  'correctCount': instance.correctCount,
  'questionCount': instance.questionCount,
};

_$MockExamQuestionMarkImpl _$$MockExamQuestionMarkImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamQuestionMarkImpl(
  questionNumber: (json['questionNumber'] as num).toInt(),
  subject: $enumDecode(
    _$MockExamSubjectEnumMap,
    json['subject'],
    unknownValue: MockExamSubject.unknown,
  ),
  isAnswered: json['isAnswered'] as bool,
  isCorrect: json['isCorrect'] as bool,
  isFlagged: json['isFlagged'] as bool,
);

Map<String, dynamic> _$$MockExamQuestionMarkImplToJson(
  _$MockExamQuestionMarkImpl instance,
) => <String, dynamic>{
  'questionNumber': instance.questionNumber,
  'subject': _$MockExamSubjectEnumMap[instance.subject]!,
  'isAnswered': instance.isAnswered,
  'isCorrect': instance.isCorrect,
  'isFlagged': instance.isFlagged,
};

_$MockExamQuestionReviewImpl _$$MockExamQuestionReviewImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamQuestionReviewImpl(
  questionNumber: (json['questionNumber'] as num).toInt(),
  subject: $enumDecode(
    _$MockExamSubjectEnumMap,
    json['subject'],
    unknownValue: MockExamSubject.unknown,
  ),
  questionUuid: json['questionUuid'] as String,
  topicName: json['topicName'] as String?,
  stem: json['stem'] as String,
  schemaDisplay: json['schemaDisplay'] as String?,
  schemaTables:
      (json['schemaTables'] as List<dynamic>?)
          ?.map((e) => QuestionSchemaTable.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  choices:
      (json['choices'] as List<dynamic>?)
          ?.map((e) => MockExamChoice.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  selectedChoiceKey: json['selectedChoiceKey'] as String?,
  correctChoiceKey: json['correctChoiceKey'] as String,
  isCorrect: json['isCorrect'] as bool,
  explanationSummary: json['explanationSummary'] as String?,
);

Map<String, dynamic> _$$MockExamQuestionReviewImplToJson(
  _$MockExamQuestionReviewImpl instance,
) => <String, dynamic>{
  'questionNumber': instance.questionNumber,
  'subject': _$MockExamSubjectEnumMap[instance.subject]!,
  'questionUuid': instance.questionUuid,
  'topicName': instance.topicName,
  'stem': instance.stem,
  'schemaDisplay': instance.schemaDisplay,
  'schemaTables': instance.schemaTables,
  'choices': instance.choices,
  'selectedChoiceKey': instance.selectedChoiceKey,
  'correctChoiceKey': instance.correctChoiceKey,
  'isCorrect': instance.isCorrect,
  'explanationSummary': instance.explanationSummary,
};

_$MockExamNextStepImpl _$$MockExamNextStepImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamNextStepImpl(
  headline: json['headline'] as String,
  message: json['message'] as String,
  actions:
      (json['actions'] as List<dynamic>?)
          ?.map((e) => AiAnalysisAction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$MockExamNextStepImplToJson(
  _$MockExamNextStepImpl instance,
) => <String, dynamic>{
  'headline': instance.headline,
  'message': instance.message,
  'actions': instance.actions,
};

_$MockExamHistoryResponseImpl _$$MockExamHistoryResponseImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamHistoryResponseImpl(
  passScore: (json['passScore'] as num).toInt(),
  attempts:
      (json['attempts'] as List<dynamic>?)
          ?.map((e) => MockExamHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$MockExamHistoryResponseImplToJson(
  _$MockExamHistoryResponseImpl instance,
) => <String, dynamic>{
  'passScore': instance.passScore,
  'attempts': instance.attempts,
};

_$MockExamHistoryEntryImpl _$$MockExamHistoryEntryImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamHistoryEntryImpl(
  attemptUuid: json['attemptUuid'] as String,
  roundNumber: (json['roundNumber'] as num).toInt(),
  title: json['title'] as String,
  submittedAt: json['submittedAt'] as String,
  totalScore: (json['totalScore'] as num).toInt(),
  subjectOneScore: (json['subjectOneScore'] as num).toInt(),
  subjectTwoScore: (json['subjectTwoScore'] as num).toInt(),
  isPassed: json['isPassed'] as bool,
  failReason: $enumDecode(
    _$MockExamFailReasonEnumMap,
    json['failReason'],
    unknownValue: MockExamFailReason.unknown,
  ),
);

Map<String, dynamic> _$$MockExamHistoryEntryImplToJson(
  _$MockExamHistoryEntryImpl instance,
) => <String, dynamic>{
  'attemptUuid': instance.attemptUuid,
  'roundNumber': instance.roundNumber,
  'title': instance.title,
  'submittedAt': instance.submittedAt,
  'totalScore': instance.totalScore,
  'subjectOneScore': instance.subjectOneScore,
  'subjectTwoScore': instance.subjectTwoScore,
  'isPassed': instance.isPassed,
  'failReason': _$MockExamFailReasonEnumMap[instance.failReason]!,
};
