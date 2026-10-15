package com.passql.member.constant;

import com.passql.common.util.RequestEnumParser;

/**
 * 푸시 알림 탭 시 앱 이동 화면 허용 목록 5종 (이름이 앱과의 와이어 계약, 변경 금지)
 * 앱 원본 대응: app/lib/core/push/push_link.dart PushLinkTarget
 */
public enum PushLinkTarget {
    HOME("홈", false),
    DAILY_SET("오늘의 세트", false),
    QUESTIONS("문제 탭", false),
    QUESTION_DETAIL("문제 상세", true),
    STATS("통계", false);

    private final String label;
    private final boolean isQuestionUuidRequired;

    PushLinkTarget(String label, boolean isQuestionUuidRequired) {
        this.label = label;
        this.isQuestionUuidRequired = isQuestionUuidRequired;
    }

    public String getLabel() {
        return label;
    }

    public boolean isQuestionUuidRequired() {
        return isQuestionUuidRequired;
    }

    /** 요청값 > PushLinkTarget (null·공백·없는 값 > INVALID_INPUT_VALUE) */
    public static PushLinkTarget fromRequestValue(String requestValue) {
        return RequestEnumParser.parse(PushLinkTarget.class, requestValue);
    }
}
