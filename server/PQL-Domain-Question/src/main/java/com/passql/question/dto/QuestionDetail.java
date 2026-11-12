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
    Boolean isLatestTrend,
    @Schema(description = "오늘의 세트 무료 체험 여부: 무료 회원이 이 문제에서 SQL 실행·AI 해설을 쓸 수 있으면 true (프로·결제 꺼짐은 false, #992)")
    Boolean isDailySetFreeTrial
) {
    /** 오늘의 세트 무료 체험 표시만 바꾼 사본 (판정은 응용 계층, #992) */
    public QuestionDetail withDailySetFreeTrial(boolean isDailySetFreeTrial) {
        return new QuestionDetail(questionUuid, topicName, subtopicName, difficulty, executionMode, choiceSetPolicy, stem,
            schemaDisplay, schemaDdl, schemaSampleData, schemaIntent, schemaTables, answerSql, hint, choiceSets,
            isLatestTrend, isDailySetFreeTrial);
    }

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
