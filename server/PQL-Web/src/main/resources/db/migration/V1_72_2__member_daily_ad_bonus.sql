-- 무료 한도 광고 보너스 기록(#808): 회원·날짜(KST)·칸(1·2) unique, 하루 2회
CREATE TABLE IF NOT EXISTS member_daily_ad_bonus (
    member_daily_ad_bonus_uuid UUID PRIMARY KEY,
    member_uuid                UUID         NOT NULL,
    bonus_date                 DATE         NOT NULL,
    slot                       INT          NOT NULL,
    granted_at                 TIMESTAMP(6) NOT NULL,
    created_at                 TIMESTAMP(6),
    updated_at                 TIMESTAMP(6),
    created_by                 VARCHAR(255),
    updated_by                 VARCHAR(255),
    CONSTRAINT uk_member_daily_ad_bonus_member_date_slot UNIQUE (member_uuid, bonus_date, slot)
);
