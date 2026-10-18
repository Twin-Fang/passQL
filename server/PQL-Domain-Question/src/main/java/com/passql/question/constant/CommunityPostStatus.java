package com.passql.question.constant;

/** 글 상태 */
public enum CommunityPostStatus {
    VISIBLE,       // 노출
    HIDDEN_AUTO,   // 신고 누적 자동 숨김 (관리자 검토 대기)
    HIDDEN_ADMIN,  // 관리자 숨김
    DELETED;       // 삭제 (본인·관리자, 내용 비움)

    public boolean isHidden() {
        return this == HIDDEN_AUTO || this == HIDDEN_ADMIN;
    }
}
