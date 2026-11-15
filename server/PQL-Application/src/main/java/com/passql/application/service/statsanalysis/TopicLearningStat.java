package com.passql.application.service.statsanalysis;

import java.util.UUID;

/**
 * 토픽 1개 학습 수치 (최근 90일 누적, 문제별 마지막 시도)
 * correctRate 0.0~1.0, isSubjectOne 은 1과목(데이터 모델링) 토픽 여부, examQuestionCount 는 시험 50문항 중 이 토픽 문항 수 (#1111)
 */
public record TopicLearningStat(UUID topicUuid, String displayName, boolean isSubjectOne,
                                int solvedCount, double correctRate, int examQuestionCount) {

    /** 출제 문항 수 모름 (점수 올리기 계산 제외) */
    public TopicLearningStat(UUID topicUuid, String displayName, boolean isSubjectOne, int solvedCount, double correctRate) {
        this(topicUuid, displayName, isSubjectOne, solvedCount, correctRate, 0);
    }

    /** 틀린 문제 수 (잃는 점수가 큰 토픽 먼저 고르는 기준) */
    public double wrongCount() {
        return solvedCount * (1 - correctRate);
    }

    public int correctCount() {
        return (int) Math.round(solvedCount * correctRate);
    }

    public int correctRatePercent() {
        return (int) Math.round(correctRate * 100);
    }
}
