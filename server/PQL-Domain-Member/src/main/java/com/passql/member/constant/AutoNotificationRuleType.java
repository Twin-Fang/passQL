package com.passql.member.constant;

/**
 * 재방문 자동 알림 규칙 5종 (이름이 auto_notification_rule.rule_type 저장값, 변경 금지)
 * hasThresholdDays: 미접속 일수를 규칙에 두는지, linkTarget 은 QUESTION_DETAIL 제외
 */
public enum AutoNotificationRuleType {
    DAILY_SET_REMINDER("오늘의 세트 리마인드", "오늘의 세트를 아직 안 푼 회원", false, AutoNotificationGroup.STUDY_REMINDER),
    STREAK_RISK("연속 학습 위험", "어제는 풀었고 오늘은 아직 안 푼 회원", false, AutoNotificationGroup.STUDY_REMINDER),
    COMEBACK_SHORT("복귀 유도 (짧은 미접속)", "마지막 접속이 정확히 N일 전인 회원", true, AutoNotificationGroup.COMEBACK),
    COMEBACK_LONG("복귀 유도 (긴 미접속)", "마지막 접속이 정확히 N일 전인 회원", true, AutoNotificationGroup.COMEBACK),
    EXAM_COUNTDOWN("시험 D-day 안내", "시험 D-30·D-7·D-1 에 전체 수신 동의 회원", false, AutoNotificationGroup.EXAM_COUNTDOWN);

    private final String label;
    private final String targetDescription;
    private final boolean hasThresholdDays;
    // 회원이 끌 수 있는 알림 그룹
    private final AutoNotificationGroup group;

    AutoNotificationRuleType(String label, String targetDescription, boolean hasThresholdDays, AutoNotificationGroup group) {
        this.label = label;
        this.targetDescription = targetDescription;
        this.hasThresholdDays = hasThresholdDays;
        this.group = group;
    }

    public String getLabel() {
        return label;
    }

    public String getTargetDescription() {
        return targetDescription;
    }

    public boolean hasThresholdDays() {
        return hasThresholdDays;
    }

    public AutoNotificationGroup getGroup() {
        return group;
    }
}
