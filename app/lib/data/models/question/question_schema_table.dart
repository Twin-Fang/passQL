import 'package:freezed_annotation/freezed_annotation.dart';

import 'question_schema_column.dart';

part 'question_schema_table.freezed.dart';
part 'question_schema_table.g.dart';

/// 문제 화면 테이블 미리보기 1개 (서버가 schemaDdl·schemaSampleData 해석, #520)
/// sampleRows: 행마다 columns 순서의 셀 값, SQL NULL 이면 null
@freezed
class QuestionSchemaTable with _$QuestionSchemaTable {
  const factory QuestionSchemaTable({
    required String tableName,
    @Default([]) List<QuestionSchemaColumn> columns,
    @Default([]) List<List<dynamic>> sampleRows,
  }) = _QuestionSchemaTable;

  factory QuestionSchemaTable.fromJson(Map<String, dynamic> json) =>
      _$QuestionSchemaTableFromJson(json);
}
