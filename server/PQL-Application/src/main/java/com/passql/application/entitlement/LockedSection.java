package com.passql.application.entitlement;

/**
 * 무료 회원 응답에서 뺀 묶음 이름: 응답의 lockedSections 에 이름(name)으로 실린다 (와이어 계약, 이름 변경 금지)
 */
public enum LockedSection {

    EXECUTION_RESULT,   // 실행 결과 표와 실행한 SQL
    FULL_EXPLANATION,   // 판정 한 줄 이후의 전체 해설
    MOCK_EXAM_SUBJECT_DETAIL,   // 모의고사 과목별 점수·토픽별 정답률·다음에 할 일 (#866)
    MOCK_EXAM_REVIEW            // 모의고사 문항별 해설 (#866)
}
