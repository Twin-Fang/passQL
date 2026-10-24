package com.passql.web.dto.report;

import com.passql.question.constant.CorrectionScope;

import java.util.List;
import java.util.UUID;

/**
 * 신고 여러 건 처리 요청: 대상 신고 UUID, 보정 범위, 문제 비활성화 여부, 사유 메모(선택, 최대 500자)
 */
public record BulkResolveRequest(
        List<UUID> reportUuids,
        CorrectionScope correctionScope,
        Boolean deactivateQuestion,
        String resolutionNote
) {}
