package com.passql.submission.dto.mockexam;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 같은 회차 응시자 중 내 위치 (회원별 첫 제출 점수 분포 기준, #1041)
 */
public record MockExamRanking(
    @Schema(description = "내 순위 (1부터, 동점은 같은 순위)") int rankPosition,
    @Schema(description = "순위 계산에 든 응시자 수 (회원 수)") int takerCount,
    @Schema(description = "상위 퍼센트 (1~100, 올림)") int topPercent) {
}
