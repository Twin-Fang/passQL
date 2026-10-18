package com.passql.question.dto.community;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 글에 첨부된 내 풀이 요약 (서버가 제출 기록으로 생성, 선택한 보기 내용은 없음)
 * solvedAt: 결과를 정한 제출 시각 (처음 맞힌 제출, 못 맞혔으면 마지막 제출), ISO-8601
 */
public record SolveSnapshot(
        Boolean isCorrect,
        Integer attemptCount,
        String solvedAt,
        @Schema(nullable = true) String topicCode,
        Integer difficulty
) {
}
