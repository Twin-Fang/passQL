-- 관리자 감사 로그, 약관 이전 본문 이력, 제재 이력 처리 관리자 (#469)

-- 관리자 변경 기록 (수정·삭제 없는 기록 테이블)
CREATE TABLE IF NOT EXISTS admin_audit_log (
    admin_audit_log_uuid UUID         PRIMARY KEY,
    admin_username       VARCHAR(50)  NOT NULL,
    target_type          VARCHAR(30)  NOT NULL,
    target_id            VARCHAR(100),
    action               VARCHAR(30)  NOT NULL,
    change_summary_json  TEXT,
    client_ip            VARCHAR(64),
    occurred_at          TIMESTAMP(6) NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_admin_audit_log_occurred_at ON admin_audit_log (occurred_at);
CREATE INDEX IF NOT EXISTS idx_admin_audit_log_admin_username ON admin_audit_log (admin_username);
CREATE INDEX IF NOT EXISTS idx_admin_audit_log_target ON admin_audit_log (target_type, target_id);

-- 약관 수정 직전 스냅숏
CREATE TABLE IF NOT EXISTS legal_history (
    legal_history_uuid UUID         PRIMARY KEY,
    type               VARCHAR(50)  NOT NULL,
    title              VARCHAR(255) NOT NULL,
    content            TEXT         NOT NULL,
    status             VARCHAR(20)  NOT NULL,
    version_at         TIMESTAMP(6),
    archived_at        TIMESTAMP(6) NOT NULL,
    created_at         TIMESTAMP(6),
    updated_at         TIMESTAMP(6),
    created_by         VARCHAR(255),
    updated_by         VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_legal_history_type_archived ON legal_history (type, archived_at);

-- 제재·해제 처리 관리자 (기존 행은 NULL, 자동 해제는 system)
ALTER TABLE member_suspend_history ADD COLUMN IF NOT EXISTS acted_by_admin_username VARCHAR(50);
