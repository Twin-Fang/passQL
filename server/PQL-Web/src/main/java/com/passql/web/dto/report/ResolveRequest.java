package com.passql.web.dto.report;

import com.passql.question.constant.CorrectionScope;

/**
 * 신고 1건 처리 요청: 보정 범위, 문제 비활성화 여부, 사유 메모(선택, 최대 500자)
 */
public record ResolveRequest(
        CorrectionScope correctionScope,
        Boolean deactivateQuestion,
        String resolutionNote
) {
    public ResolveRequest(CorrectionScope correctionScope, Boolean deactivateQuestion) {
        this(correctionScope, deactivateQuestion, null);
    }
}
