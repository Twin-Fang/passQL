package com.passql.submission.dto.mockexam;

import java.util.UUID;

/**
 * 회차 순위 계산용 제출 응시 1건 (회원, 총점), 제출 시각 오름차순으로 조회
 */
public record MockExamRoundScoreProjection(UUID memberUuid, int totalScore) {
}
