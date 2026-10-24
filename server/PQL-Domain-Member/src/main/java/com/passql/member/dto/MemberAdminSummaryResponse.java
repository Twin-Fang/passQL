package com.passql.member.dto;

/** 관리자 회원 목록 상단 요약: 상태별 회원 수와 프로 이용 중 회원 수 */
public record MemberAdminSummaryResponse(
    long totalCount,
    long activeCount,
    long suspendedCount,
    long dormantCount,
    long withdrawnCount,
    long proActiveCount
) {
}
