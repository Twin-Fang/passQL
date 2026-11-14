// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_answer_sheet_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExamAnswerSheetRequestImpl _$$ExamAnswerSheetRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ExamAnswerSheetRequestImpl(
  clientToken: json['clientToken'] as String,
  answers: json['answers'] as String,
  source: json['source'] as String,
);

Map<String, dynamic> _$$ExamAnswerSheetRequestImplToJson(
  _$ExamAnswerSheetRequestImpl instance,
) => <String, dynamic>{
  'clientToken': instance.clientToken,
  'answers': instance.answers,
  'source': instance.source,
};

_$ExamAnswerGradeResultImpl _$$ExamAnswerGradeResultImplFromJson(
  Map<String, dynamic> json,
) => _$ExamAnswerGradeResultImpl(
  subject1: ExamAnswerSubjectGrade.fromJson(
    json['subject1'] as Map<String, dynamic>,
  ),
  subject2: ExamAnswerSubjectGrade.fromJson(
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
  percentile: (json['percentile'] as num?)?.toDouble(),
  perQuestion:
      (json['perQuestion'] as List<dynamic>?)
          ?.map(
            (e) => ExamAnswerQuestionGrade.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ExamAnswerGradeResultImplToJson(
  _$ExamAnswerGradeResultImpl instance,
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

_$ExamAnswerSubjectGradeImpl _$$ExamAnswerSubjectGradeImplFromJson(
  Map<String, dynamic> json,
) => _$ExamAnswerSubjectGradeImpl(
  score: (json['score'] as num).toInt(),
  max: (json['max'] as num).toInt(),
  isFailCut: json['isFailCut'] as bool? ?? false,
);

Map<String, dynamic> _$$ExamAnswerSubjectGradeImplToJson(
  _$ExamAnswerSubjectGradeImpl instance,
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

_$ExamAnswerQuestionGradeImpl _$$ExamAnswerQuestionGradeImplFromJson(
  Map<String, dynamic> json,
) => _$ExamAnswerQuestionGradeImpl(
  questionNo: (json['questionNo'] as num).toInt(),
  myAnswer: (json['myAnswer'] as num?)?.toInt() ?? 0,
  answer: (json['answer'] as num?)?.toInt(),
  isCorrect: json['isCorrect'] as bool?,
);

Map<String, dynamic> _$$ExamAnswerQuestionGradeImplToJson(
  _$ExamAnswerQuestionGradeImpl instance,
) => <String, dynamic>{
  'questionNo': instance.questionNo,
  'myAnswer': instance.myAnswer,
  'answer': instance.answer,
  'isCorrect': instance.isCorrect,
};
