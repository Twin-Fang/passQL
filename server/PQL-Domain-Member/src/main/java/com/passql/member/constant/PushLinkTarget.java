package com.passql.member.constant;

import com.passql.common.util.RequestEnumParser;

/**
 * 푸시 알림 탭 시 앱 이동 화면 허용 목록 6종 (이름이 앱과의 와이어 계약, 변경 금지)
 * 앱 원본 대응: app/lib/core/push/push_link.dart PushLinkTarget (모르는 값은 앱이 이동 없이 무시)
 */
public enum PushLinkTarget {
    HOME("홈", false),
    DAILY_SET("오늘의 세트", false),
    QUESTIONS("문제 탭", false),
    QUESTION_DETAIL("문제 상세", true),
    STATS("통계", false),
    // 시험 일정 화면 (#991, 앱 라우트 EXAM_SCHEDULE_APP_ROUTE 예약, 앱 미구현 버전은 이동 없이 열림)
    EXAM_SCHEDULE("시험 일정", false);

    // 시험 일정 화면 앱 라우트 (예약, 앱에서 나중에 구현)
    public static final String EXAM_SCHEDULE_APP_ROUTE = "/exam-schedule";

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
