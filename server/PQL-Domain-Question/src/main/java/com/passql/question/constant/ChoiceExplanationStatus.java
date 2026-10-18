package com.passql.question.constant;

/**
 * 선택지 세트 AI 해설 상태 (#521): GENERATING 생성 중, READY 저장본 있음, FAILED 생성 실패 (재시도 상한까지 다시 시도)
 * DB(question_choice_set.explanation_status)와 해설 조회 API 응답에 같은 이름으로 쓰인다 (와이어 계약, 이름 변경 금지)
 */
public enum ChoiceExplanationStatus {
    GENERATING,
    READY,
    FAILED
}
