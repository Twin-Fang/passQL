// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_comment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiCommentResponseImpl _$$AiCommentResponseImplFromJson(
  Map<String, dynamic> json,
) => _$AiCommentResponseImpl(
  comment: json['comment'] as String,
  generatedAt: json['generatedAt'] as String?,
  analysis: json['analysis'] == null
      ? null
      : AiStatsAnalysis.fromJson(json['analysis'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$AiCommentResponseImplToJson(
  _$AiCommentResponseImpl instance,
) => <String, dynamic>{
  'comment': instance.comment,
  'generatedAt': instance.generatedAt,
  'analysis': instance.analysis,
};
