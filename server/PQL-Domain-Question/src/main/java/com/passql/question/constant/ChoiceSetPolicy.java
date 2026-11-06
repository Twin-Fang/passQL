package com.passql.question.constant;

import com.passql.common.util.RequestEnumParser;

/**
 * 문제가 선택지를 어떻게 공급받는지 결정하는 정책.
 * CURATED_ONLY: 관리자 검증 고정 보기만 출제 (실전·연습 공통, 표시 순서 섞기, #511). HYBRID 는 스키마 예약.
 * ODD_ONE_OUT: "결과가 다른 것은?" 유형 — 4개 중 3개가 동일 결과, 1개만 다른 결과를 정답으로 판별.
 * RESULT_MATCH: "다음 SQL의 실행 결과로 올바른 것은?" 유형 — 선택지 body가 JSON 배열 형태의 결과 테이블.
 */
public enum ChoiceSetPolicy {
    AI_ONLY("AI 생성 (기본)", true),
    CURATED_ONLY("고정 보기 (JSON 가져오기로 보기와 함께 등록)", false),
    HYBRID("AI + 직접 작성 혼합 (예약, 미지원)", false),
    ODD_ONE_OUT("결과가 다른 것은? 유형", true),
    RESULT_MATCH("실행 결과로 올바른 것은? 유형", true);

    // 관리자 화면 표시 이름
    private final String displayName;
    // 문제 직접 등록 폼에서 보기 없이 고를 수 있는지 (고정 보기는 보기 입력 필요, HYBRID 는 출제 미구현)
    private final boolean isDirectRegistrationAllowed;

    ChoiceSetPolicy(String displayName, boolean isDirectRegistrationAllowed) {
        this.displayName = displayName;
        this.isDirectRegistrationAllowed = isDirectRegistrationAllowed;
    }

    public String getDisplayName() {
        return displayName;
    }

    public boolean isDirectRegistrationAllowed() {
        return isDirectRegistrationAllowed;
    }

    /** 요청값 > ChoiceSetPolicy (null·공백·없는 값 > INVALID_INPUT_VALUE) */
    public static ChoiceSetPolicy fromRequestValue(String requestValue) {
        return RequestEnumParser.parse(ChoiceSetPolicy.class, requestValue);
    }
}
