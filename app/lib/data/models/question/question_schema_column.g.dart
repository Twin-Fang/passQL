// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_schema_column.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuestionSchemaColumnImpl _$$QuestionSchemaColumnImplFromJson(
  Map<String, dynamic> json,
) => _$QuestionSchemaColumnImpl(
  name: json['name'] as String,
  type: json['type'] as String? ?? '',
  isPrimaryKey: json['isPrimaryKey'] as bool? ?? false,
  isForeignKey: json['isForeignKey'] as bool? ?? false,
);

Map<String, dynamic> _$$QuestionSchemaColumnImplToJson(
  _$QuestionSchemaColumnImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'type': instance.type,
  'isPrimaryKey': instance.isPrimaryKey,
  'isForeignKey': instance.isForeignKey,
};
