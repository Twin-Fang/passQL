// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accuracy_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccuracyDetailResponseImpl _$$AccuracyDetailResponseImplFromJson(
  Map<String, dynamic> json,
) => _$AccuracyDetailResponseImpl(
  difficultyStats:
      (json['difficultyStats'] as List<dynamic>?)
          ?.map((e) => DifficultyStat.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  everWrongQuestionCount:
      (json['everWrongQuestionCount'] as num?)?.toInt() ?? 0,
  clearedWrongQuestionCount:
      (json['clearedWrongQuestionCount'] as num?)?.toInt() ?? 0,
  remainingWrongTrend:
      (json['remainingWrongTrend'] as List<dynamic>?)
          ?.map((e) => WeeklyWrongCount.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$AccuracyDetailResponseImplToJson(
  _$AccuracyDetailResponseImpl instance,
) => <String, dynamic>{
  'difficultyStats': instance.difficultyStats,
  'everWrongQuestionCount': instance.everWrongQuestionCount,
  'clearedWrongQuestionCount': instance.clearedWrongQuestionCount,
  'remainingWrongTrend': instance.remainingWrongTrend,
};
