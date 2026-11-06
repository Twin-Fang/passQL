package com.passql.ai.constant;

/**
 * 통계 AI 분석 토픽 판정 3종 (#861): WEAK 약점(정답률 60% 미만), SHAKY 불안정(75% 미만), UNTRIED 판단 이름(5문제 미만)
 * 안정권(75% 이상) 토픽은 분석 대상이 아니라 응답에 나오지 않음
 */
public enum AiFindingKind {
    WEAK,
    SHAKY,
    UNTRIED
}
