-- =============================================================================
-- V1_133_2: OX 퀴즈 카드 복습 상태 (#1083)
-- ox_card_review: 회원·카드당 1행, Leitner 칸(1~5)과 다음 출제 시각 (KST 그날 0시)
-- card_key: "{개념 uuid}:{바로 확인 문장 SHA-256 앞 16자}"
-- =============================================================================

CREATE TABLE IF NOT EXISTS ox_card_review (
    ox_card_review_uuid UUID         PRIMARY KEY,
    member_uuid         UUID         NOT NULL,
    card_key            VARCHAR(80)  NOT NULL,
    box                 INTEGER      NOT NULL,
    due_at              TIMESTAMP(6) NOT NULL,
    last_answered_at    TIMESTAMP(6) NOT NULL,
    correct_streak      INTEGER      NOT NULL,
    created_at          TIMESTAMP(6),
    updated_at          TIMESTAMP(6),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255),
    CONSTRAINT uk_ox_card_review_member_card UNIQUE (member_uuid, card_key)
);

-- 회원별 기한 지난 카드 조회
CREATE INDEX IF NOT EXISTS idx_ox_card_review_member_due
    ON ox_card_review (member_uuid, due_at);
