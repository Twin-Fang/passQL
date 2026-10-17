// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_schema_table.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuestionSchemaTableImpl _$$QuestionSchemaTableImplFromJson(
  Map<String, dynamic> json,
) => _$QuestionSchemaTableImpl(
  tableName: json['tableName'] as String,
  columns:
      (json['columns'] as List<dynamic>?)
          ?.map((e) => QuestionSchemaColumn.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  sampleRows:
      (json['sampleRows'] as List<dynamic>?)
          ?.map((e) => e as List<dynamic>)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$QuestionSchemaTableImplToJson(
  _$QuestionSchemaTableImpl instance,
) => <String, dynamic>{
  'tableName': instance.tableName,
  'columns': instance.columns,
  'sampleRows': instance.sampleRows,
};
