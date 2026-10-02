// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wrong_questions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WrongQuestionItemImpl _$$WrongQuestionItemImplFromJson(
  Map<String, dynamic> json,
) => _$WrongQuestionItemImpl(
  questionUuid: json['questionUuid'] as String,
  stemPreview: json['stemPreview'] as String,
  topicName: json['topicName'] as String?,
  lastWrongAt: json['lastWrongAt'] == null
      ? null
      : DateTime.parse(json['lastWrongAt'] as String),
);

Map<String, dynamic> _$$WrongQuestionItemImplToJson(
  _$WrongQuestionItemImpl instance,
) => <String, dynamic>{
  'questionUuid': instance.questionUuid,
  'stemPreview': instance.stemPreview,
  'topicName': instance.topicName,
  'lastWrongAt': instance.lastWrongAt?.toIso8601String(),
};

_$WrongQuestionsResponseImpl _$$WrongQuestionsResponseImplFromJson(
  Map<String, dynamic> json,
) => _$WrongQuestionsResponseImpl(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => WrongQuestionItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$WrongQuestionsResponseImplToJson(
  _$WrongQuestionsResponseImpl instance,
) => <String, dynamic>{
  'items': instance.items,
  'totalCount': instance.totalCount,
};
