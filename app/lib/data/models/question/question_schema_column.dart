import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_schema_column.freezed.dart';
part 'question_schema_column.g.dart';

/// 테이블 미리보기 컬럼: 이름, 타입(DDL 표기, 없으면 빈 문자열), 키 여부 2개(PK, FK)
@freezed
class QuestionSchemaColumn with _$QuestionSchemaColumn {
  const factory QuestionSchemaColumn({
    required String name,
    @Default('') String type,
    @Default(false) bool isPrimaryKey,
    @Default(false) bool isForeignKey,
  }) = _QuestionSchemaColumn;

  factory QuestionSchemaColumn.fromJson(Map<String, dynamic> json) =>
      _$QuestionSchemaColumnFromJson(json);
}
