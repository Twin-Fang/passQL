// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sqld_exam_schedule_overview_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SqldExamScheduleOverviewResponseImpl
_$$SqldExamScheduleOverviewResponseImplFromJson(Map<String, dynamic> json) =>
    _$SqldExamScheduleOverviewResponseImpl(
      year: (json['year'] as num).toInt(),
      schedules:
          (json['schedules'] as List<dynamic>?)
              ?.map(
                (e) => ExamScheduleResponse.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ExamScheduleResponse>[],
      nextSchedule: json['nextSchedule'] == null
          ? null
          : ExamScheduleResponse.fromJson(
              json['nextSchedule'] as Map<String, dynamic>,
            ),
      lastCollectedAt: json['lastCollectedAt'] == null
          ? null
          : DateTime.parse(json['lastCollectedAt'] as String),
      officialScheduleUrl: json['officialScheduleUrl'] as String?,
    );

Map<String, dynamic> _$$SqldExamScheduleOverviewResponseImplToJson(
  _$SqldExamScheduleOverviewResponseImpl instance,
) => <String, dynamic>{
  'year': instance.year,
  'schedules': instance.schedules,
  'nextSchedule': instance.nextSchedule,
  'lastCollectedAt': instance.lastCollectedAt?.toIso8601String(),
  'officialScheduleUrl': instance.officialScheduleUrl,
};
