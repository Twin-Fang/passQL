package com.passql.web.dto.report;

/**
 * 신고 일괄 처리 결과: 처리한 건 수, 이미 처리돼 건너뛴 건 수
 */
public record BulkReportProcessResponse(
        int processedCount,
        int skippedCount
) {}
