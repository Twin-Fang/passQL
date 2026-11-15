// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hardest_questions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HardestQuestionItemImpl _$$HardestQuestionItemImplFromJson(
  Map<String, dynamic> json,
) => _$HardestQuestionItemImpl(
  rank: (json['rank'] as num).toInt(),
  questionUuid: json['questionUuid'] as String,
  stemPreview: json['stemPreview'] as String,
  topicName: json['topicName'] as String?,
  subject:
      $enumDecodeNullable(
        _$MockExamSubjectEnumMap,
        json['subject'],
        unknownValue: MockExamSubject.unknown,
      ) ??
      MockExamSubject.unknown,
  wrongRatePercent: (json['wrongRatePercent'] as num?)?.toDouble() ?? 0,
  attemptCount: (json['attemptCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$HardestQuestionItemImplToJson(
  _$HardestQuestionItemImpl instance,
) => <String, dynamic>{
  'rank': instance.rank,
  'questionUuid': instance.questionUuid,
  'stemPreview': instance.stemPreview,
  'topicName': instance.topicName,
  'subject': _$MockExamSubjectEnumMap[instance.subject]!,
  'wrongRatePercent': instance.wrongRatePercent,
  'attemptCount': instance.attemptCount,
};

const _$MockExamSubjectEnumMap = {
  MockExamSubject.subjectOne: 'SUBJECT_ONE',
  MockExamSubject.subjectTwo: 'SUBJECT_TWO',
  MockExamSubject.unknown: 'unknown',
};

_$HardestQuestionsResponseImpl _$$HardestQuestionsResponseImplFromJson(
  Map<String, dynamic> json,
) => _$HardestQuestionsResponseImpl(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => HardestQuestionItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  aggregatedAt: json['aggregatedAt'] == null
      ? null
      : DateTime.parse(json['aggregatedAt'] as String),
  minimumAttemptCount: (json['minimumAttemptCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$HardestQuestionsResponseImplToJson(
  _$HardestQuestionsResponseImpl instance,
) => <String, dynamic>{
  'items': instance.items,
  'aggregatedAt': instance.aggregatedAt?.toIso8601String(),
  'minimumAttemptCount': instance.minimumAttemptCount,
};
