package com.passql.application.entitlement;

/**
 * 회차 패스(프로) 전용 기능 목록: 서버 잠금 판정 단위
 */
public enum ProFeature {

    SQL_EXECUTION,      // 문제 SQL 직접 실행
    FULL_EXPLANATION,   // 해설 전체 보기
    ERROR_EXPLANATION,  // 오답·에러 해설
    REAL_MODE,          // 실전 모드
    TOPIC_PRACTICE,     // 토픽별 연습
    RECOMMENDATION,     // 추천 문제
    EXAM_TREND,         // 기출 경향
    TOPIC_ANALYSIS,     // 토픽 분석
    AI_COMMENT          // AI 코멘트
}
