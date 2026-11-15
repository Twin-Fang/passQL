package com.passql.application.service.statsanalysis;

import com.passql.ai.dto.AiScoreGainTopic;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 점수 올리기 좋은 영역 (#1111): 출제 문항 수 × (75% − 내 정답률) × 2점, 근거 부족 제외, 큰 순 3개
 */
class ScoreGainTopicCalculatorTest {

    private static TopicLearningStat topic(String displayName, int solvedCount, double correctRate, int examQuestionCount) {
        return new TopicLearningStat(UUID.nameUUIDFromBytes(displayName.getBytes()), displayName, false,
                solvedCount, correctRate, examQuestionCount);
    }

    @Test
    void 출제_비중이_큰_약한_영역이_먼저_오고_근거_부족_영역은_빠진다() {
        List<AiScoreGainTopic> topics = ScoreGainTopicCalculator.selectTopTopics(List.of(
                topic("데이터 모델링의 이해", 10, 0.5, 10),   // 10 × 0.25 × 2 = 5.0
                topic("조인 (JOIN)", 8, 0.45, 5),            // 5 × 0.30 × 2 = 3.0
                topic("서브쿼리", 4, 0.0, 5),                // 4문제: 근거 부족
                topic("윈도우 함수", 6, 0.9, 5),             // 목표 넘음
                topic("관리 구문", 6, 0.6, 6),               // 6 × 0.15 × 2 = 1.8
                topic("계층형 질의", 6, 0.6, 3)));           // 3 × 0.15 × 2 = 0.9

        assertThat(topics).extracting(AiScoreGainTopic::topicName).containsExactly("데이터 모델링의 이해", "조인", "관리 구문");
        assertThat(topics).extracting(AiScoreGainTopic::expectedGainScore).containsExactly(5.0, 3.0, 1.8);
    }
}
