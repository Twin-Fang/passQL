-- 커뮤니티 (#525): 범용 글, 좋아요, 신고, 차단, 문제별 토론 집계
-- Hibernate ddl-auto=update 도 같은 테이블을 만들지만 FK·CHECK·부분 인덱스는 여기서만 만든다
CREATE TABLE IF NOT EXISTS community_post (
    post_uuid           UUID PRIMARY KEY,
    board_type          VARCHAR(30)  NOT NULL,
    target_type         VARCHAR(30)  NOT NULL,
    target_uuid         UUID,
    author_member_uuid  UUID         NOT NULL,
    content             VARCHAR(500) NOT NULL,
    status              VARCHAR(20)  NOT NULL,
    like_count          INTEGER      NOT NULL DEFAULT 0,
    comment_count       INTEGER      NOT NULL DEFAULT 0,
    report_count        INTEGER      NOT NULL DEFAULT 0,
    solve_snapshot      JSONB,
    handled_by          VARCHAR(100),
    created_at          TIMESTAMP(6),
    updated_at          TIMESTAMP(6),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255),
    CONSTRAINT fk_community_post_author FOREIGN KEY (author_member_uuid) REFERENCES member (member_uuid),
    CONSTRAINT ck_community_post_board_type CHECK (board_type IN ('QUESTION_OPINION', 'EXAM_REVIEW', 'FREE', 'QNA')),
    CONSTRAINT ck_community_post_target_type CHECK (target_type IN ('QUESTION', 'EXAM_ROUND', 'NONE')),
    CONSTRAINT ck_community_post_status CHECK (status IN ('VISIBLE', 'HIDDEN_AUTO', 'HIDDEN_ADMIN', 'DELETED')),
    -- 삭제된 글만 내용이 비어 있을 수 있음
    CONSTRAINT ck_community_post_content CHECK (status = 'DELETED' OR char_length(content) BETWEEN 1 AND 500),
    CONSTRAINT ck_community_post_counts CHECK (like_count >= 0 AND comment_count >= 0 AND report_count >= 0),
    -- NONE 이 아니면 대상 식별자 필수
    CONSTRAINT ck_community_post_target CHECK (target_type = 'NONE' OR target_uuid IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS idx_community_post_target_status_created
    ON community_post (board_type, target_type, target_uuid, status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_community_post_author_created
    ON community_post (author_member_uuid, created_at DESC);
-- 노출 가능한 글만 (문제별 목록이 숨김·삭제 글을 읽지 않게)
CREATE INDEX IF NOT EXISTS idx_community_post_visible_target_created
    ON community_post (target_uuid, created_at DESC, post_uuid DESC) WHERE status = 'VISIBLE';
CREATE INDEX IF NOT EXISTS idx_community_post_visible_target_likes
    ON community_post (target_uuid, like_count DESC, created_at DESC) WHERE status = 'VISIBLE';
-- 관리자 신고 목록
CREATE INDEX IF NOT EXISTS idx_community_post_reported
    ON community_post (report_count DESC, created_at DESC) WHERE report_count > 0 OR status IN ('HIDDEN_AUTO', 'HIDDEN_ADMIN');

CREATE TABLE IF NOT EXISTS community_post_like (
    post_like_uuid UUID PRIMARY KEY,
    post_uuid      UUID NOT NULL,
    member_uuid    UUID NOT NULL,
    created_at     TIMESTAMP(6),
    updated_at     TIMESTAMP(6),
    created_by     VARCHAR(255),
    updated_by     VARCHAR(255),
    CONSTRAINT fk_community_post_like_post FOREIGN KEY (post_uuid) REFERENCES community_post (post_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_community_post_like_member FOREIGN KEY (member_uuid) REFERENCES member (member_uuid),
    CONSTRAINT uk_community_post_like_member UNIQUE (post_uuid, member_uuid)
);
CREATE INDEX IF NOT EXISTS idx_community_post_like_member ON community_post_like (member_uuid);

-- 글·댓글 공용 신고 (대상이 글·댓글로 나뉘어 target_uuid 에는 FK 를 걸지 않음)
CREATE TABLE IF NOT EXISTS community_report (
    report_uuid          UUID PRIMARY KEY,
    target_type          VARCHAR(20)  NOT NULL,
    target_uuid          UUID         NOT NULL,
    reporter_member_uuid UUID         NOT NULL,
    category             VARCHAR(30)  NOT NULL,
    detail               VARCHAR(200),
    status               VARCHAR(20)  NOT NULL,
    created_at           TIMESTAMP(6),
    updated_at           TIMESTAMP(6),
    created_by           VARCHAR(255),
    updated_by           VARCHAR(255),
    CONSTRAINT fk_community_report_reporter FOREIGN KEY (reporter_member_uuid) REFERENCES member (member_uuid),
    CONSTRAINT ck_community_report_target_type CHECK (target_type IN ('POST', 'COMMENT')),
    CONSTRAINT ck_community_report_category CHECK (category IN ('ABUSE', 'SPAM', 'ANSWER_SPOILER', 'ETC')),
    CONSTRAINT ck_community_report_status CHECK (status IN ('PENDING', 'RESOLVED', 'DISMISSED')),
    CONSTRAINT uk_community_report_reporter UNIQUE (target_type, target_uuid, reporter_member_uuid)
);
CREATE INDEX IF NOT EXISTS idx_community_report_target_status
    ON community_report (target_type, target_uuid, status);
CREATE INDEX IF NOT EXISTS idx_community_report_reporter ON community_report (reporter_member_uuid);

CREATE TABLE IF NOT EXISTS member_block (
    member_block_uuid   UUID PRIMARY KEY,
    blocker_member_uuid UUID NOT NULL,
    blocked_member_uuid UUID NOT NULL,
    created_at          TIMESTAMP(6),
    updated_at          TIMESTAMP(6),
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255),
    CONSTRAINT fk_member_block_blocker FOREIGN KEY (blocker_member_uuid) REFERENCES member (member_uuid),
    CONSTRAINT fk_member_block_blocked FOREIGN KEY (blocked_member_uuid) REFERENCES member (member_uuid),
    CONSTRAINT ck_member_block_not_self CHECK (blocker_member_uuid <> blocked_member_uuid),
    CONSTRAINT uk_member_block_pair UNIQUE (blocker_member_uuid, blocked_member_uuid)
);
CREATE INDEX IF NOT EXISTS idx_member_block_blocked ON member_block (blocked_member_uuid);

-- 문제별 토론 집계 (피드용, 5분마다 갱신, PK = 문제 UUID)
CREATE TABLE IF NOT EXISTS question_discussion_stats (
    question_uuid    UUID PRIMARY KEY,
    post_count       INTEGER          NOT NULL DEFAULT 0,
    like_count       INTEGER          NOT NULL DEFAULT 0,
    hot_score        DOUBLE PRECISION NOT NULL DEFAULT 0,
    last_activity_at TIMESTAMP(6)     NOT NULL,
    created_at       TIMESTAMP(6),
    updated_at       TIMESTAMP(6),
    created_by       VARCHAR(255),
    updated_by       VARCHAR(255),
    CONSTRAINT fk_question_discussion_stats_question FOREIGN KEY (question_uuid) REFERENCES question (question_uuid) ON DELETE CASCADE,
    CONSTRAINT ck_question_discussion_stats_counts CHECK (post_count >= 0 AND like_count >= 0)
);
CREATE INDEX IF NOT EXISTS idx_question_discussion_stats_hot ON question_discussion_stats (hot_score DESC);
