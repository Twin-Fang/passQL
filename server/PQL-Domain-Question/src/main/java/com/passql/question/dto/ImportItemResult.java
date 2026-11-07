package com.passql.question.dto;

import java.util.List;

/**
 * 가져오기 항목 1건 검증 결과: 실행 상태(OK·SKIP·FAIL)·사유 + 형식 위반 목록(#905, 없으면 빈 목록)
 */
public record ImportItemResult(
    int index,
    String stemPreview,
    String topicCode,
    Integer difficulty,
    String executionMode,
    String sandboxStatus,
    Integer sandboxRowCount,
    Long sandboxElapsedMs,
    String sandboxError,
    String importAction,
    List<QuestionFormatViolation> formatViolations
) {

    /** 형식 위반 없는 결과 */
    public ImportItemResult(int index, String stemPreview, String topicCode, Integer difficulty, String executionMode,
                            String sandboxStatus, Integer sandboxRowCount, Long sandboxElapsedMs, String sandboxError,
                            String importAction) {
        this(index, stemPreview, topicCode, difficulty, executionMode, sandboxStatus, sandboxRowCount,
                sandboxElapsedMs, sandboxError, importAction, List.of());
    }
}
