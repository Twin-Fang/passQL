// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'difficulty_stat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DifficultyStatImpl _$$DifficultyStatImplFromJson(Map<String, dynamic> json) =>
    _$DifficultyStatImpl(
      difficulty: (json['difficulty'] as num).toInt(),
      solvedCount: (json['solvedCount'] as num?)?.toInt() ?? 0,
      correctRate: (json['correctRate'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$DifficultyStatImplToJson(
  _$DifficultyStatImpl instance,
) => <String, dynamic>{
  'difficulty': instance.difficulty,
  'solvedCount': instance.solvedCount,
  'correctRate': instance.correctRate,
};
