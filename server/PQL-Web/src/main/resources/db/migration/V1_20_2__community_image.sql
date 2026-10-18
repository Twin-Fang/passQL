-- 커뮤니티 이미지 (#525 3단계): 업로드 이미지, 글-이미지 연결
-- 저장 형식은 항상 WebP, 객체는 MinIO 버킷 passql 의 community/ 접두사 (community/tmp/ 는 미첨부 임시, 24시간 뒤 정리)
CREATE TABLE IF NOT EXISTS community_image (
    image_uuid           UUID PRIMARY KEY,
    owner_member_uuid    UUID         NOT NULL,
    object_key           VARCHAR(255) NOT NULL,
    thumbnail_key        VARCHAR(255) NOT NULL,
    byte_size            INTEGER      NOT NULL,
    thumbnail_byte_size  INTEGER      NOT NULL,
    width_pixels         INTEGER      NOT NULL,
    height_pixels        INTEGER      NOT NULL,
    status               VARCHAR(20)  NOT NULL,
    created_at           TIMESTAMP(6),
    updated_at           TIMESTAMP(6),
    created_by           VARCHAR(255),
    updated_by           VARCHAR(255),
    CONSTRAINT fk_community_image_owner FOREIGN KEY (owner_member_uuid) REFERENCES member (member_uuid),
    -- TEMP 업로드만 됨, ATTACHED 글에 연결됨, DELETED 객체 삭제됨
    CONSTRAINT ck_community_image_status CHECK (status IN ('TEMP', 'ATTACHED', 'DELETED')),
    CONSTRAINT ck_community_image_size CHECK (byte_size > 0 AND thumbnail_byte_size > 0 AND width_pixels > 0 AND height_pixels > 0)
);
CREATE INDEX IF NOT EXISTS idx_community_image_owner_created ON community_image (owner_member_uuid, created_at DESC);
-- 임시 이미지 정리 작업용
CREATE INDEX IF NOT EXISTS idx_community_image_temp_created ON community_image (created_at) WHERE status = 'TEMP';

CREATE TABLE IF NOT EXISTS community_post_image (
    post_image_uuid  UUID PRIMARY KEY,
    post_uuid        UUID    NOT NULL,
    image_uuid       UUID    NOT NULL,
    sort_order       INTEGER NOT NULL,
    created_at       TIMESTAMP(6),
    updated_at       TIMESTAMP(6),
    created_by       VARCHAR(255),
    updated_by       VARCHAR(255),
    CONSTRAINT fk_community_post_image_post FOREIGN KEY (post_uuid) REFERENCES community_post (post_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_community_post_image_image FOREIGN KEY (image_uuid) REFERENCES community_image (image_uuid),
    -- 이미지 1장은 글 1개에만 연결
    CONSTRAINT uk_community_post_image_image UNIQUE (image_uuid),
    CONSTRAINT uk_community_post_image_order UNIQUE (post_uuid, sort_order)
);
