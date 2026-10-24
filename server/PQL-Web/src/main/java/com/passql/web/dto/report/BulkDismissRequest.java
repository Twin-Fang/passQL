package com.passql.web.dto.report;

import java.util.List;
import java.util.UUID;

/**
 * 신고 여러 건 기각 요청: 대상 신고 UUID, 사유 메모(선택, 최대 500자)
 */
public record BulkDismissRequest(
        List<UUID> reportUuids,
        String resolutionNote
) {}
