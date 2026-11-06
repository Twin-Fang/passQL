// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_exam_sheet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MockExamSheetResponseImpl _$$MockExamSheetResponseImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamSheetResponseImpl(
  attemptUuid: json['attemptUuid'] as String,
  roundUuid: json['roundUuid'] as String,
  roundNumber: (json['roundNumber'] as num).toInt(),
  title: json['title'] as String,
  status: $enumDecode(
    _$MockExamAttemptStatusEnumMap,
    json['status'],
    unknownValue: MockExamAttemptStatus.unknown,
  ),
  remainingSeconds: (json['remainingSeconds'] as num).toInt(),
  questions:
      (json['questions'] as List<dynamic>?)
          ?.map(
            (e) => MockExamSheetQuestion.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$$MockExamSheetResponseImplToJson(
  _$MockExamSheetResponseImpl instance,
) => <String, dynamic>{
  'attemptUuid': instance.attemptUuid,
  'roundUuid': instance.roundUuid,
  'roundNumber': instance.roundNumber,
  'title': instance.title,
  'status': _$MockExamAttemptStatusEnumMap[instance.status]!,
  'remainingSeconds': instance.remainingSeconds,
  'questions': instance.questions,
};

const _$MockExamAttemptStatusEnumMap = {
  MockExamAttemptStatus.inProgress: 'IN_PROGRESS',
  MockExamAttemptStatus.submitted: 'SUBMITTED',
  MockExamAttemptStatus.unknown: 'unknown',
};

_$MockExamSheetQuestionImpl _$$MockExamSheetQuestionImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamSheetQuestionImpl(
  questionNumber: (json['questionNumber'] as num).toInt(),
  subject: $enumDecode(
    _$MockExamSubjectEnumMap,
    json['subject'],
    unknownValue: MockExamSubject.unknown,
  ),
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
  isFlagged: json['isFlagged'] as bool? ?? false,
);

Map<String, dynamic> _$$MockExamSheetQuestionImplToJson(
  _$MockExamSheetQuestionImpl instance,
) => <String, dynamic>{
  'questionNumber': instance.questionNumber,
  'subject': _$MockExamSubjectEnumMap[instance.subject]!,
  'topicName': instance.topicName,
  'stem': instance.stem,
  'schemaDisplay': instance.schemaDisplay,
  'schemaTables': instance.schemaTables,
  'choices': instance.choices,
  'selectedChoiceKey': instance.selectedChoiceKey,
  'isFlagged': instance.isFlagged,
};

const _$MockExamSubjectEnumMap = {
  MockExamSubject.subjectOne: 'SUBJECT_ONE',
  MockExamSubject.subjectTwo: 'SUBJECT_TWO',
  MockExamSubject.unknown: 'unknown',
};

_$MockExamChoiceImpl _$$MockExamChoiceImplFromJson(Map<String, dynamic> json) =>
    _$MockExamChoiceImpl(
      key: json['key'] as String,
      kind: json['kind'] as String,
      body: json['body'] as String,
      isCorrect: json['isCorrect'] as bool?,
      rationale: json['rationale'] as String?,
    );

Map<String, dynamic> _$$MockExamChoiceImplToJson(
  _$MockExamChoiceImpl instance,
) => <String, dynamic>{
  'key': instance.key,
  'kind': instance.kind,
  'body': instance.body,
  'isCorrect': instance.isCorrect,
  'rationale': instance.rationale,
};

_$MockExamAnswerSaveRequestImpl _$$MockExamAnswerSaveRequestImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamAnswerSaveRequestImpl(
  selectedChoiceKey: json['selectedChoiceKey'] as String?,
  isFlagged: json['isFlagged'] as bool,
);

Map<String, dynamic> _$$MockExamAnswerSaveRequestImplToJson(
  _$MockExamAnswerSaveRequestImpl instance,
) => <String, dynamic>{
  'selectedChoiceKey': instance.selectedChoiceKey,
  'isFlagged': instance.isFlagged,
};

_$MockExamAnswerSaveResponseImpl _$$MockExamAnswerSaveResponseImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamAnswerSaveResponseImpl(
  questionNumber: (json['questionNumber'] as num).toInt(),
  remainingSeconds: (json['remainingSeconds'] as num).toInt(),
);

Map<String, dynamic> _$$MockExamAnswerSaveResponseImplToJson(
  _$MockExamAnswerSaveResponseImpl instance,
) => <String, dynamic>{
  'questionNumber': instance.questionNumber,
  'remainingSeconds': instance.remainingSeconds,
};

_$MockExamSubmitRequestImpl _$$MockExamSubmitRequestImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamSubmitRequestImpl(
  answers:
      (json['answers'] as List<dynamic>?)
          ?.map((e) => MockExamAnswerEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$MockExamSubmitRequestImplToJson(
  _$MockExamSubmitRequestImpl instance,
) => <String, dynamic>{'answers': instance.answers};

_$MockExamAnswerEntryImpl _$$MockExamAnswerEntryImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamAnswerEntryImpl(
  questionNumber: (json['questionNumber'] as num).toInt(),
  selectedChoiceKey: json['selectedChoiceKey'] as String?,
  isFlagged: json['isFlagged'] as bool? ?? false,
);

Map<String, dynamic> _$$MockExamAnswerEntryImplToJson(
  _$MockExamAnswerEntryImpl instance,
) => <String, dynamic>{
  'questionNumber': instance.questionNumber,
  'selectedChoiceKey': instance.selectedChoiceKey,
  'isFlagged': instance.isFlagged,
};
