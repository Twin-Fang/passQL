package com.passql.question.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import com.passql.question.constant.ChoiceKind;
import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.constant.ExecutionMode;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record QuestionDetail(
    UUID questionUuid,
    @Schema(nullable = true) String topicName,
    @Schema(nullable = true) String subtopicName,
    Integer difficulty,
    @Schema(nullable = true) ExecutionMode executionMode,
    ChoiceSetPolicy choiceSetPolicy,
    String stem,
    @Schema(nullable = true) String schemaDisplay,
    @Schema(nullable = true) String schemaDdl,
    @Schema(nullable = true) String schemaSampleData,
    @Schema(nullable = true) String schemaIntent,
    @Schema(description = "테이블 미리보기 (schemaDdl + schemaSampleData 해석, 스키마 없으면 빈 목록, #520)")
    List<QuestionSchemaTable> schemaTables,
    @Schema(nullable = true) String answerSql,
    @Schema(nullable = true) String hint,
    List<ChoiceSetSummary> choiceSets,
    @Schema(description = "최신 출제 경향 반영 문제 여부 ('최신 경향' 배지, #523)")
    Boolean isLatestTrend
) {
    public record ChoiceSetSummary(
        UUID choiceSetUuid,
        ChoiceSetSource source,
        ChoiceSetStatus status,
        @Schema(nullable = true) Boolean sandboxValidationPassed,
        LocalDateTime createdAt,
        List<ChoiceItem> items
    ) {}

    public record ChoiceItem(String key, ChoiceKind kind, String body, @Schema(nullable = true) Boolean isCorrect, @Schema(nullable = true) String rationale, @Schema(nullable = true) Integer sortOrder) {}
}
