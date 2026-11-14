// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_answer_sheet_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExamAnswerSheetSubmitRequestImpl _$$ExamAnswerSheetSubmitRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ExamAnswerSheetSubmitRequestImpl(
  clientToken: json['clientToken'] as String,
  answers: json['answers'] as String,
  source: json['source'] as String,
);

Map<String, dynamic> _$$ExamAnswerSheetSubmitRequestImplToJson(
  _$ExamAnswerSheetSubmitRequestImpl instance,
) => <String, dynamic>{
  'clientToken': instance.clientToken,
  'answers': instance.answers,
  'source': instance.source,
};

_$ExamAnswerSheetResponseImpl _$$ExamAnswerSheetResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ExamAnswerSheetResponseImpl(
  certType: json['certType'] as String,
  roundNumber: (json['roundNumber'] as num).toInt(),
  answers: json['answers'] as String,
  source: json['source'] as String?,
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
  result: json['result'] == null
      ? null
      : ExamAnswerGradingResponse.fromJson(
          json['result'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$$ExamAnswerSheetResponseImplToJson(
  _$ExamAnswerSheetResponseImpl instance,
) => <String, dynamic>{
  'certType': instance.certType,
  'roundNumber': instance.roundNumber,
  'answers': instance.answers,
  'source': instance.source,
  'submittedAt': instance.submittedAt?.toIso8601String(),
  'result': instance.result,
};

_$ExamAnswerGradingResponseImpl _$$ExamAnswerGradingResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ExamAnswerGradingResponseImpl(
  subject1: ExamAnswerSubjectScoreResponse.fromJson(
    json['subject1'] as Map<String, dynamic>,
  ),
  subject2: ExamAnswerSubjectScoreResponse.fromJson(
    json['subject2'] as Map<String, dynamic>,
  ),
  totalScore: (json['totalScore'] as num).toInt(),
  scoreRange: json['scoreRange'] == null
      ? null
      : ExamAnswerScoreRangeResponse.fromJson(
          json['scoreRange'] as Map<String, dynamic>,
        ),
  passStatus:
      $enumDecodeNullable(
        _$ExamAnswerPassStatusValueEnumMap,
        json['passStatus'],
        unknownValue: ExamAnswerPassStatusValue.unknown,
      ) ??
      ExamAnswerPassStatusValue.unknown,
  percentile: (json['percentile'] as num?)?.toInt(),
  perQuestion:
      (json['perQuestion'] as List<dynamic>?)
          ?.map(
            (e) => ExamAnswerQuestionResultResponse.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ExamAnswerGradingResponseImplToJson(
  _$ExamAnswerGradingResponseImpl instance,
) => <String, dynamic>{
  'subject1': instance.subject1,
  'subject2': instance.subject2,
  'totalScore': instance.totalScore,
  'scoreRange': instance.scoreRange,
  'passStatus': _$ExamAnswerPassStatusValueEnumMap[instance.passStatus]!,
  'percentile': instance.percentile,
  'perQuestion': instance.perQuestion,
};

const _$ExamAnswerPassStatusValueEnumMap = {
  ExamAnswerPassStatusValue.pass: 'PASS',
  ExamAnswerPassStatusValue.fail: 'FAIL',
  ExamAnswerPassStatusValue.borderline: 'BORDERLINE',
  ExamAnswerPassStatusValue.unknown: 'unknown',
};

_$ExamAnswerSubjectScoreResponseImpl
_$$ExamAnswerSubjectScoreResponseImplFromJson(Map<String, dynamic> json) =>
    _$ExamAnswerSubjectScoreResponseImpl(
      score: (json['score'] as num).toInt(),
      max: (json['max'] as num).toInt(),
      isFailCut: json['isFailCut'] as bool? ?? false,
    );

Map<String, dynamic> _$$ExamAnswerSubjectScoreResponseImplToJson(
  _$ExamAnswerSubjectScoreResponseImpl instance,
) => <String, dynamic>{
  'score': instance.score,
  'max': instance.max,
  'isFailCut': instance.isFailCut,
};

_$ExamAnswerScoreRangeResponseImpl _$$ExamAnswerScoreRangeResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ExamAnswerScoreRangeResponseImpl(
  min: (json['min'] as num).toInt(),
  max: (json['max'] as num).toInt(),
);

Map<String, dynamic> _$$ExamAnswerScoreRangeResponseImplToJson(
  _$ExamAnswerScoreRangeResponseImpl instance,
) => <String, dynamic>{'min': instance.min, 'max': instance.max};

_$ExamAnswerQuestionResultResponseImpl
_$$ExamAnswerQuestionResultResponseImplFromJson(Map<String, dynamic> json) =>
    _$ExamAnswerQuestionResultResponseImpl(
      questionNo: (json['questionNo'] as num).toInt(),
      myAnswer: (json['myAnswer'] as num?)?.toInt() ?? 0,
      answer: (json['answer'] as num?)?.toInt(),
      isCorrect: json['isCorrect'] as bool?,
    );

Map<String, dynamic> _$$ExamAnswerQuestionResultResponseImplToJson(
  _$ExamAnswerQuestionResultResponseImpl instance,
) => <String, dynamic>{
  'questionNo': instance.questionNo,
  'myAnswer': instance.myAnswer,
  'answer': instance.answer,
  'isCorrect': instance.isCorrect,
};
