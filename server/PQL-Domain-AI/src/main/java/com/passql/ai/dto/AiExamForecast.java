package com.passql.ai.dto;

import com.passql.ai.constant.AiForecastVerdict;

/**
 * SQLD 과목별 예상 점수 (#862): 최근 90일 정답률 > 1과목 10문항·2과목 40문항 기준 예상 맞힐 문제 수 > 100점 환산·판정
 * summary 예: "1과목 예상 6/10 · 2과목 예상 26/40", detail 예: "합격선까지 2문제 더 맞히면 돼요" / 과락 경고
 */
public record AiExamForecast(
        int expectedScore,
        int subjectOneExpectedCount,
        int subjectOneQuestionCount,
        Boolean isSubjectOneFailRisk,
        int subjectTwoExpectedCount,
        int subjectTwoQuestionCount,
        Boolean isSubjectTwoFailRisk,
        AiForecastVerdict verdict,
        String verdictLabel,
        String summary,
        String detail
) {}
