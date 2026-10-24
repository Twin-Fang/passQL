package com.passql.common.audit.constant;

/**
 * 관리자 감사 로그 동작 (admin_audit_log.action)
 */
public enum AdminAuditAction {
    CREATE("등록"),
    UPDATE("수정"),
    DELETE("삭제"),
    DEACTIVATE("비활성화"),
    RESTORE("복구"),
    ACTIVATE("활성화"),
    STATUS_CHANGE("상태 변경"),
    IMPORT("가져오기"),
    SUSPEND("제재"),
    UNSUSPEND("제재 해제"),
    WITHDRAW("탈퇴 처리"),
    RESOLVE("처리 완료"),
    DISMISS("기각"),
    PASSWORD_RESET("비밀번호 재설정"),
    UNLOCK("잠금 해제"),
    SEND("발송"),
    RETRACT("회수"),
    HIDE("숨김"),
    // 관리자 접근 이벤트 (대상 = 관리자 계정)
    LOGIN("로그인"),
    LOGIN_FAILURE("로그인 실패"),
    ROLE_CHANGE("권한 변경"),
    REINDEX("재색인");

    // 화면 표시 이름
    private final String label;

    AdminAuditAction(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
