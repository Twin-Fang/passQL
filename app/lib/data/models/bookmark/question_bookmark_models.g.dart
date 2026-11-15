// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_bookmark_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuestionBookmarkItemImpl _$$QuestionBookmarkItemImplFromJson(
  Map<String, dynamic> json,
) => _$QuestionBookmarkItemImpl(
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
  bookmarkedAt: json['bookmarkedAt'] == null
      ? null
      : DateTime.parse(json['bookmarkedAt'] as String),
);

Map<String, dynamic> _$$QuestionBookmarkItemImplToJson(
  _$QuestionBookmarkItemImpl instance,
) => <String, dynamic>{
  'questionUuid': instance.questionUuid,
  'stemPreview': instance.stemPreview,
  'topicName': instance.topicName,
  'subject': _$MockExamSubjectEnumMap[instance.subject]!,
  'bookmarkedAt': instance.bookmarkedAt?.toIso8601String(),
};

const _$MockExamSubjectEnumMap = {
  MockExamSubject.subjectOne: 'SUBJECT_ONE',
  MockExamSubject.subjectTwo: 'SUBJECT_TWO',
  MockExamSubject.unknown: 'unknown',
};

_$QuestionBookmarksResponseImpl _$$QuestionBookmarksResponseImplFromJson(
  Map<String, dynamic> json,
) => _$QuestionBookmarksResponseImpl(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => QuestionBookmarkItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
  page: (json['page'] as num?)?.toInt() ?? 0,
  hasNext: json['hasNext'] as bool? ?? false,
);

Map<String, dynamic> _$$QuestionBookmarksResponseImplToJson(
  _$QuestionBookmarksResponseImpl instance,
) => <String, dynamic>{
  'items': instance.items,
  'totalCount': instance.totalCount,
  'page': instance.page,
  'hasNext': instance.hasNext,
};

_$QuestionBookmarkStatusResponseImpl
_$$QuestionBookmarkStatusResponseImplFromJson(Map<String, dynamic> json) =>
    _$QuestionBookmarkStatusResponseImpl(
      questionUuid: json['questionUuid'] as String,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );

Map<String, dynamic> _$$QuestionBookmarkStatusResponseImplToJson(
  _$QuestionBookmarkStatusResponseImpl instance,
) => <String, dynamic>{
  'questionUuid': instance.questionUuid,
  'isBookmarked': instance.isBookmarked,
};

_$QuestionBookmarkPracticeSetResponseImpl
_$$QuestionBookmarkPracticeSetResponseImplFromJson(Map<String, dynamic> json) =>
    _$QuestionBookmarkPracticeSetResponseImpl(
      questionUuids:
          (json['questionUuids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$QuestionBookmarkPracticeSetResponseImplToJson(
  _$QuestionBookmarkPracticeSetResponseImpl instance,
) => <String, dynamic>{'questionUuids': instance.questionUuids};
