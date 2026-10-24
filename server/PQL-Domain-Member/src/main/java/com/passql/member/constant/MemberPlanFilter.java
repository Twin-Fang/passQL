package com.passql.member.constant;

/** 관리자 회원 목록 이용권 필터: 프로 이용 중, 프로 만료 임박(7일 이내) */
public enum MemberPlanFilter {
    PRO_ACTIVE("프로 이용 중"),
    PRO_EXPIRING("프로 만료 임박(7일)");

    // 관리자 화면 표시 이름
    private final String label;

    MemberPlanFilter(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
