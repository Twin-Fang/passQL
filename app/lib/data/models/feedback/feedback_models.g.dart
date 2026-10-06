// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeedbackItemImpl _$$FeedbackItemImplFromJson(Map<String, dynamic> json) =>
    _$FeedbackItemImpl(
      feedbackUuid: json['feedbackUuid'] as String,
      content: json['content'] as String,
      status:
          $enumDecodeNullable(
            _$FeedbackStatusEnumMap,
            json['status'],
            unknownValue: FeedbackStatus.pending,
          ) ??
          FeedbackStatus.pending,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$FeedbackItemImplToJson(_$FeedbackItemImpl instance) =>
    <String, dynamic>{
      'feedbackUuid': instance.feedbackUuid,
      'content': instance.content,
      'status': _$FeedbackStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$FeedbackStatusEnumMap = {
  FeedbackStatus.pending: 'PENDING',
  FeedbackStatus.reviewed: 'REVIEWED',
  FeedbackStatus.applied: 'APPLIED',
};

_$FeedbackListResponseImpl _$$FeedbackListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$FeedbackListResponseImpl(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => FeedbackItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$FeedbackListResponseImplToJson(
  _$FeedbackListResponseImpl instance,
) => <String, dynamic>{'items': instance.items};
