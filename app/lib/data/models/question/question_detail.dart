import 'package:freezed_annotation/freezed_annotation.dart';
import 'choice_set_summary.dart';
import 'question_schema_table.dart';

part 'question_detail.freezed.dart';
part 'question_detail.g.dart';

/// 문제 상세 응답. executionMode에 따라 UI 분기.
/// EXECUTABLE: SQL 실행 + 스키마 표시
/// CONCEPT_ONLY: 텍스트 선택지만 표시
@freezed
class QuestionDetail with _$QuestionDetail {
  const factory QuestionDetail({
    required String questionUuid,
    String? topicName,
    String? subtopicName,
    int? difficulty,
    String? executionMode,
    required String stem,
    String? schemaDisplay,
    String? schemaDdl,
    String? schemaSampleData,
    String? schemaIntent,
    // 테이블 미리보기 (구버전 서버면 빈 목록 > 화면이 DDL 원문으로 대체, #520)
    @Default([]) List<QuestionSchemaTable> schemaTables,
    String? answerSql,
    String? hint,
    @Default([]) List<ChoiceSetSummary> choiceSets,
  }) = _QuestionDetail;

  factory QuestionDetail.fromJson(Map<String, dynamic> json) =>
      _$QuestionDetailFromJson(json);
}
