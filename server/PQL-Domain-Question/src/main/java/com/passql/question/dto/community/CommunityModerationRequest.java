package com.passql.question.dto.community;

import com.passql.question.entity.CommunityReport;
import jakarta.validation.constraints.Size;

/** 관리자 글·신고 처리 요청: 처리 사유 메모(선택, 신고 처리 기록에 남음) */
public record CommunityModerationRequest(@Size(max = CommunityReport.MAX_HANDLED_NOTE_LENGTH) String reason) {

    /** 본문 없이 호출된 처리 요청 */
    public static CommunityModerationRequest empty() {
        return new CommunityModerationRequest(null);
    }
}
