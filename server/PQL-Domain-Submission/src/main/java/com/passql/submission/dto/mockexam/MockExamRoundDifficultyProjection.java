package com.passql.submission.dto.mockexam;

import java.util.UUID;

/**
 * 회차별 문항 평균 난이도 (1~5, 회차 목록 난이도 표시, #1084)
 */
public record MockExamRoundDifficultyProjection(UUID roundUuid, Double averageDifficulty) {
}
