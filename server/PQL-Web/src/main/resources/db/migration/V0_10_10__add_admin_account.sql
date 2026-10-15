-- 관리자 계정·역할·로그인 잠금 (#478)
-- 기본 계정(yml admin.username)은 기동 시 AdminAccountSeeder 가 행을 만들고 해시를 동기화 (비밀번호 해시를 SQL 에 두지 않음)
CREATE TABLE IF NOT EXISTS admin_account (
    admin_account_uuid      UUID         PRIMARY KEY,
    username                VARCHAR(50)  NOT NULL,
    password_hash           VARCHAR(100) NOT NULL,
    role                    VARCHAR(20)  NOT NULL,
    is_enabled              BOOLEAN      NOT NULL DEFAULT TRUE,
    is_environment_managed  BOOLEAN      NOT NULL DEFAULT FALSE,
    failed_login_count      INTEGER      NOT NULL DEFAULT 0,
    locked_until            TIMESTAMP(6),
    last_login_at           TIMESTAMP(6),
    last_login_ip           VARCHAR(64),
    created_at              TIMESTAMP(6),
    updated_at              TIMESTAMP(6),
    created_by              VARCHAR(255),
    updated_by              VARCHAR(255),
    CONSTRAINT uk_admin_account_username UNIQUE (username)
);
