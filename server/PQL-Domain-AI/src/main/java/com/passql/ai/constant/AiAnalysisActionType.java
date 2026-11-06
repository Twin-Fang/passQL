package com.passql.ai.constant;

/**
 * 통계 AI 분석 바로 풀기 버튼 4종 (#861, #862): PRACTICE_TOPIC 토픽 풀기, REVIEW_WRONG 오답 다시 풀기, RANDOM_PRACTICE 랜덤 풀기(데이터 부족), PRACTICE_LATEST_TREND 최신 경향(모두 안정권)
 * 화면이 모르는 종류는 버튼을 숨김 (구버전 앱 호환)
 */
public enum AiAnalysisActionType {
    PRACTICE_TOPIC,
    REVIEW_WRONG,
    RANDOM_PRACTICE,
    PRACTICE_LATEST_TREND
}
