package com.passql.ai.constant;

/**
 * SQLD 예상 점수 판정 4종 (#862): 과락 위험 > 합격권 > 합격선 근처 > 합격선 아래 순으로 판정
 * SUBJECT_FAIL_RISK 과목 하나라도 40% 미만, PASS_LIKELY 70점 이상, BORDERLINE 54~68점, BELOW_PASS 54점 미만
 */
public enum AiForecastVerdict {
    SUBJECT_FAIL_RISK,
    PASS_LIKELY,
    BORDERLINE,
    BELOW_PASS
}
