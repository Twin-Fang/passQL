package com.passql.question.constant;

/** 신고 처리 상태 */
public enum CommunityReportStatus {
    PENDING,   // 검토 대기
    RESOLVED,  // 처리 완료 (숨김·삭제 반영)
    DISMISSED  // 기각
}
