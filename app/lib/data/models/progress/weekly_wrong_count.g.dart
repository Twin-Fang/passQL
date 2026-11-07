// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_wrong_count.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeeklyWrongCountImpl _$$WeeklyWrongCountImplFromJson(
  Map<String, dynamic> json,
) => _$WeeklyWrongCountImpl(
  weekStartDate: json['weekStartDate'] as String,
  remainingWrongCount: (json['remainingWrongCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$WeeklyWrongCountImplToJson(
  _$WeeklyWrongCountImpl instance,
) => <String, dynamic>{
  'weekStartDate': instance.weekStartDate,
  'remainingWrongCount': instance.remainingWrongCount,
};
