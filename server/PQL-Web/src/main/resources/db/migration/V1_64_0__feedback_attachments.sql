-- 의견 보내기 개편(#708): 진단 정보·로그 첨부 컬럼, 이미지 첨부 테이블
ALTER TABLE feedback ADD COLUMN IF NOT EXISTS diagnostics TEXT;
ALTER TABLE feedback ADD COLUMN IF NOT EXISTS app_version VARCHAR(40);
ALTER TABLE feedback ADD COLUMN IF NOT EXISTS platform VARCHAR(20);
ALTER TABLE feedback ADD COLUMN IF NOT EXISTS os_version VARCHAR(40);
ALTER TABLE feedback ADD COLUMN IF NOT EXISTS device_model VARCHAR(100);
ALTER TABLE feedback ADD COLUMN IF NOT EXISTS log_object_key VARCHAR(200);
ALTER TABLE feedback ADD COLUMN IF NOT EXISTS log_bytes INT;

CREATE TABLE IF NOT EXISTS feedback_image (
    feedback_image_uuid CHAR(36)     NOT NULL,
    feedback_uuid       CHAR(36)     NOT NULL,
    object_key          VARCHAR(200) NOT NULL,
    bytes               INT          NOT NULL,
    width_pixels        INT          NOT NULL,
    height_pixels       INT          NOT NULL,
    sort_order          INT          NOT NULL,
    created_at          TIMESTAMP(6),
    updated_at          TIMESTAMP(6),
    created_by          VARCHAR(255) NULL,
    updated_by          VARCHAR(255) NULL,
    PRIMARY KEY (feedback_image_uuid)
);

CREATE INDEX IF NOT EXISTS idx_feedback_image_feedback_uuid ON feedback_image (feedback_uuid);
