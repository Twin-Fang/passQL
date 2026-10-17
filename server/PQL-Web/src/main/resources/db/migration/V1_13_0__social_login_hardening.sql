-- 소셜 로그인 강화 (#516)
-- 1. 활성 회원의 (제공자, 제공자 사용자 ID) 유일성: 동시 가입으로 같은 소셜 계정 회원이 2명 생기는 것 차단
--    탈퇴 회원(is_deleted = true)은 provider_user_id 가 'withdrawn:{uuid}' 로 바뀌고 제외 대상이라 재가입과 충돌하지 않음
--    운영 활성 회원 중복 0건 확인 후 추가 (2026-10-18)
CREATE UNIQUE INDEX IF NOT EXISTS uk_member_provider_active
    ON member (auth_provider, provider_user_id)
    WHERE is_deleted = false;

-- 2. 탈퇴 시 제공자 연결 해제용 자격 (GitHub access, 네이버 access·refresh), 토큰은 암호문(enc:v1:...)만 저장
--    회원과 1:1 이라 member_uuid 가 PK, 연결 해제 후 행 삭제
CREATE TABLE IF NOT EXISTS member_social_credential (
    member_uuid             UUID PRIMARY KEY,
    auth_provider           VARCHAR(30) NOT NULL,
    encrypted_access_token  TEXT        NOT NULL,
    encrypted_refresh_token TEXT,
    created_at              TIMESTAMP(6),
    updated_at              TIMESTAMP(6),
    created_by              VARCHAR(255),
    updated_by              VARCHAR(255)
);
