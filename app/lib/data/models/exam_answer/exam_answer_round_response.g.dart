// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_answer_round_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExamAnswerRoundResponseImpl _$$ExamAnswerRoundResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ExamAnswerRoundResponseImpl(
  certType: json['certType'] as String,
  roundNumber: (json['roundNumber'] as num).toInt(),
  title: json['title'] as String? ?? '',
  examDate: json['examDate'] as String?,
  status:
      $enumDecodeNullable(
        _$ExamAnswerRoundStatusEnumMap,
        json['status'],
        unknownValue: ExamAnswerRoundStatus.unknown,
      ) ??
      ExamAnswerRoundStatus.unknown,
  notice: json['notice'] as String?,
  gradingRule: json['gradingRule'] == null
      ? null
      : ExamAnswerGradingRuleResponse.fromJson(
          json['gradingRule'] as Map<String, dynamic>,
        ),
  participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  items:
      (json['items'] as List<dynamic>?)
          ?.map(
            (e) => ExamAnswerItemResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ExamAnswerRoundResponseImplToJson(
  _$ExamAnswerRoundResponseImpl instance,
) => <String, dynamic>{
  'certType': instance.certType,
  'roundNumber': instance.roundNumber,
  'title': instance.title,
  'examDate': instance.examDate,
  'status': _$ExamAnswerRoundStatusEnumMap[instance.status]!,
  'notice': instance.notice,
  'gradingRule': instance.gradingRule,
  'participantCount': instance.participantCount,
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'items': instance.items,
};

const _$ExamAnswerRoundStatusEnumMap = {
  ExamAnswerRoundStatus.collecting: 'COLLECTING',
  ExamAnswerRoundStatus.official: 'OFFICIAL',
  ExamAnswerRoundStatus.closed: 'CLOSED',
  ExamAnswerRoundStatus.unknown: 'unknown',
};

_$ExamAnswerGradingRuleResponseImpl
_$$ExamAnswerGradingRuleResponseImplFromJson(Map<String, dynamic> json) =>
    _$ExamAnswerGradingRuleResponseImpl(
      totalQuestionCount: (json['totalQuestionCount'] as num).toInt(),
      pointsPerQuestion: (json['pointsPerQuestion'] as num).toInt(),
      maxScore: (json['maxScore'] as num).toInt(),
      passScore: (json['passScore'] as num).toInt(),
      subjectFailBelowPercent:
          (json['subjectFailBelowPercent'] as num?)?.toInt() ?? 0,
      subjects:
          (json['subjects'] as List<dynamic>?)
              ?.map(
                (e) => ExamAnswerSubjectRuleResponse.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ExamAnswerGradingRuleResponseImplToJson(
  _$ExamAnswerGradingRuleResponseImpl instance,
) => <String, dynamic>{
  'totalQuestionCount': instance.totalQuestionCount,
  'pointsPerQuestion': instance.pointsPerQuestion,
  'maxScore': instance.maxScore,
  'passScore': instance.passScore,
  'subjectFailBelowPercent': instance.subjectFailBelowPercent,
  'subjects': instance.subjects,
};

_$ExamAnswerSubjectRuleResponseImpl
_$$ExamAnswerSubjectRuleResponseImplFromJson(Map<String, dynamic> json) =>
    _$ExamAnswerSubjectRuleResponseImpl(
      subjectNo: (json['subjectNo'] as num).toInt(),
      subjectName: json['subjectName'] as String? ?? '',
      firstQuestionNo: (json['firstQuestionNo'] as num).toInt(),
      lastQuestionNo: (json['lastQuestionNo'] as num).toInt(),
      maxScore: (json['maxScore'] as num).toInt(),
      failBelowScore: (json['failBelowScore'] as num).toInt(),
    );

Map<String, dynamic> _$$ExamAnswerSubjectRuleResponseImplToJson(
  _$ExamAnswerSubjectRuleResponseImpl instance,
) => <String, dynamic>{
  'subjectNo': instance.subjectNo,
  'subjectName': instance.subjectName,
  'firstQuestionNo': instance.firstQuestionNo,
  'lastQuestionNo': instance.lastQuestionNo,
  'maxScore': instance.maxScore,
  'failBelowScore': instance.failBelowScore,
};

_$ExamAnswerItemResponseImpl _$$ExamAnswerItemResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ExamAnswerItemResponseImpl(
  questionNo: (json['questionNo'] as num).toInt(),
  subjectNo: (json['subjectNo'] as num).toInt(),
  conceptTitle: json['conceptTitle'] as String?,
  conceptTags:
      (json['conceptTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  topicCode: json['topicCode'] as String?,
  answer: (json['answer'] as num?)?.toInt(),
  answerStatus:
      $enumDecodeNullable(
        _$ExamAnswerItemStatusEnumMap,
        json['answerStatus'],
        unknownValue: ExamAnswerItemStatus.unknown,
      ) ??
      ExamAnswerItemStatus.undecided,
  alternativeAnswers:
      (json['alternativeAnswers'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  tally:
      (json['tally'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
  agreementRate: (json['agreementRate'] as num?)?.toDouble() ?? 0,
  note: json['note'] as String?,
);

Map<String, dynamic> _$$ExamAnswerItemResponseImplToJson(
  _$ExamAnswerItemResponseImpl instance,
) => <String, dynamic>{
  'questionNo': instance.questionNo,
  'subjectNo': instance.subjectNo,
  'conceptTitle': instance.conceptTitle,
  'conceptTags': instance.conceptTags,
  'topicCode': instance.topicCode,
  'answer': instance.answer,
  'answerStatus': _$ExamAnswerItemStatusEnumMap[instance.answerStatus]!,
  'alternativeAnswers': instance.alternativeAnswers,
  'tally': instance.tally,
  'voteCount': instance.voteCount,
  'agreementRate': instance.agreementRate,
  'note': instance.note,
};

const _$ExamAnswerItemStatusEnumMap = {
  ExamAnswerItemStatus.undecided: 'UNKNOWN',
  ExamAnswerItemStatus.leading: 'LEADING',
  ExamAnswerItemStatus.disputed: 'DISPUTED',
  ExamAnswerItemStatus.confirmed: 'CONFIRMED',
  ExamAnswerItemStatus.official: 'OFFICIAL',
  ExamAnswerItemStatus.unknown: 'unknown',
};
