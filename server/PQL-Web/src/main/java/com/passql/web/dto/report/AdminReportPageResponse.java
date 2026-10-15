package com.passql.web.dto.report;

import java.util.List;

/**
 * 관리자 신고 집계 목록 한 페이지 (#479)
 * totalReportCount·pendingReportCount: 필터 범위 전체 합계 (페이지 합계 아님)
 */
public record AdminReportPageResponse(
        List<AdminReportSummary> content,
        int page,
        int size,
        long totalElements,
        int totalPages,
        long totalReportCount,
        long pendingReportCount
) {}
