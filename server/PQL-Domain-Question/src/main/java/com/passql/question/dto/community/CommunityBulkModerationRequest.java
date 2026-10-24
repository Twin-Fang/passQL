package com.passql.question.dto.community;

import com.passql.question.entity.CommunityReport;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;

import java.util.List;
import java.util.UUID;

/** 관리자 글 일괄 처리 요청 (최대 100건): 같은 처리 사유 메모 적용 */
public record CommunityBulkModerationRequest(
        @NotEmpty @Size(max = 100) List<UUID> postUuids,
        @Size(max = CommunityReport.MAX_HANDLED_NOTE_LENGTH) String reason
) {
}
