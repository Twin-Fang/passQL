package com.passql.common.audit.constant;

/**
 * 관리자 감사 로그 대상 종류 (admin_audit_log.target_type, 화면 필터 값)
 */
public enum AdminAuditTargetType {
    QUESTION("문제"),
    CHOICE_SET("선택지 세트"),
    TOPIC("토픽"),
    APP_SETTING("앱 설정"),
    LEGAL("약관"),
    MEMBER("회원"),
    REPORT("신고"),
    FEEDBACK("건의"),
    PROMPT("프롬프트"),
    EXAM_SCHEDULE("시험 일정"),
    CONCEPT_DOC("개념 문서"),
    DAILY_CHALLENGE("일일 챌린지"),
    NOTICE("공지"),
    ADMIN_ACCOUNT("관리자 계정");

    // 화면 표시 이름
    private final String label;

    AdminAuditTargetType(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
