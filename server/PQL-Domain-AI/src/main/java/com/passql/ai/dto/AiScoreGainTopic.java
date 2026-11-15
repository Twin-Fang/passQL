package com.passql.ai.dto;

import java.util.UUID;

/**
 * 점수 올리기 좋은 영역 1건 (#1111): 시험 출제 문항 수 × (안정권 정답률 − 내 정답률) × 2점 = 기대 상승 점수
 * topicName 은 표시용 짧은 이름, expectedGainScore 는 소수 첫째 자리 반올림 (예: 3.6)
 */
public record AiScoreGainTopic(
        UUID topicUuid,
        String topicName,
        int correctRatePercent,
        // 목표 정답률 (안정권 시작, 화면 "정답률 75%까지 올리면" 표기)
        int targetCorrectRatePercent,
        int examQuestionCount,
        double expectedGainScore
) {}
