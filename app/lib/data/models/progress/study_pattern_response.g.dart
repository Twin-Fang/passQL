// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_pattern_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudyPatternResponseImpl _$$StudyPatternResponseImplFromJson(
  Map<String, dynamic> json,
) => _$StudyPatternResponseImpl(
  dailyWindowDays: (json['dailyWindowDays'] as num?)?.toInt() ?? 28,
  dailyRecords:
      (json['dailyRecords'] as List<dynamic>?)
          ?.map((e) => HeatmapEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  recentAttemptCount: (json['recentAttemptCount'] as num?)?.toInt() ?? 0,
  recentCorrectCount: (json['recentCorrectCount'] as num?)?.toInt() ?? 0,
  recentStudyDayCount: (json['recentStudyDayCount'] as num?)?.toInt() ?? 0,
  accuracyChangePoints: (json['accuracyChangePoints'] as num?)?.toInt(),
  patternWindowDays: (json['patternWindowDays'] as num?)?.toInt() ?? 84,
  weekdayAttemptCounts:
      (json['weekdayAttemptCounts'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  hourAttemptCounts:
      (json['hourAttemptCounts'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  patternAttemptCount: (json['patternAttemptCount'] as num?)?.toInt() ?? 0,
  minimumPatternAttemptCount:
      (json['minimumPatternAttemptCount'] as num?)?.toInt() ?? 10,
  busiestWeekdayIndex: (json['busiestWeekdayIndex'] as num?)?.toInt(),
  busiestHour: (json['busiestHour'] as num?)?.toInt(),
  totalStudyDayCount: (json['totalStudyDayCount'] as num?)?.toInt() ?? 0,
  longestStreakDays: (json['longestStreakDays'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$StudyPatternResponseImplToJson(
  _$StudyPatternResponseImpl instance,
) => <String, dynamic>{
  'dailyWindowDays': instance.dailyWindowDays,
  'dailyRecords': instance.dailyRecords,
  'recentAttemptCount': instance.recentAttemptCount,
  'recentCorrectCount': instance.recentCorrectCount,
  'recentStudyDayCount': instance.recentStudyDayCount,
  'accuracyChangePoints': instance.accuracyChangePoints,
  'patternWindowDays': instance.patternWindowDays,
  'weekdayAttemptCounts': instance.weekdayAttemptCounts,
  'hourAttemptCounts': instance.hourAttemptCounts,
  'patternAttemptCount': instance.patternAttemptCount,
  'minimumPatternAttemptCount': instance.minimumPatternAttemptCount,
  'busiestWeekdayIndex': instance.busiestWeekdayIndex,
  'busiestHour': instance.busiestHour,
  'totalStudyDayCount': instance.totalStudyDayCount,
  'longestStreakDays': instance.longestStreakDays,
};
