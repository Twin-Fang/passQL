package com.passql.question.dto.community;

/**
 * 관리자 신고 처리 통계 (처리 기록 도입 이후 처리분 기준)
 * handledDays 기간의 처리 완료·기각 건수와 평균 처리 시간(시간 단위, 처리분이 없으면 null)
 */
public record AdminCommunityReportStats(
        long pendingReportCount,
        long resolvedCount,
        long dismissedCount,
        int handledDays,
        Double averageHandlingHours
) {
}
