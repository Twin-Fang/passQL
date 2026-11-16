// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_exam_study_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MockExamStudySetResponseImpl _$$MockExamStudySetResponseImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamStudySetResponseImpl(
  roundUuid: json['roundUuid'] as String,
  title: json['title'] as String,
  questionUuids: (json['questionUuids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$MockExamStudySetResponseImplToJson(
  _$MockExamStudySetResponseImpl instance,
) => <String, dynamic>{
  'roundUuid': instance.roundUuid,
  'title': instance.title,
  'questionUuids': instance.questionUuids,
};
