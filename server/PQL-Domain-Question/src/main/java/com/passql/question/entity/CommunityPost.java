package com.passql.question.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.question.constant.CommunityBoardType;
import com.passql.question.constant.CommunityPostStatus;
import com.passql.question.constant.CommunityTargetType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.UUID;

/**
 * 커뮤니티 글 (#525): 게시판 종류 + 대상(문제 등) 범용 구조, 1차는 문제별 의견
 * 카운터는 DB 원자 갱신, 삭제는 status=DELETED 로 내용만 비우고 행 유지
 */
@Entity
@Table(
    name = "community_post",
    indexes = {
        @Index(name = "idx_community_post_target_status_created",
            columnList = "board_type, target_type, target_uuid, status, created_at"),
        @Index(name = "idx_community_post_author_created", columnList = "author_member_uuid, created_at")
    }
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class CommunityPost extends BaseEntity {

    // 글 본문 최대 길이 (문자 수)
    public static final int MAX_CONTENT_LENGTH = 500;
    // 숨김·삭제 주체 표기: 신고 누적 자동 처리
    public static final String HANDLED_BY_AUTO_REPORT = "AUTO_REPORT";

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID postUuid;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private CommunityBoardType boardType;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private CommunityTargetType targetType;

    // targetType 이 NONE 이면 null
    private UUID targetUuid;

    @Column(nullable = false)
    private UUID authorMemberUuid;

    // 삭제되면 빈 문자열
    @Column(length = MAX_CONTENT_LENGTH, nullable = false)
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private CommunityPostStatus status;

    @Column(nullable = false)
    private Integer likeCount;

    // 3단계 댓글용 예약
    @Column(nullable = false)
    private Integer commentCount;

    // 검토 대기 신고 수 (서로 다른 회원 기준)
    @Column(nullable = false)
    private Integer reportCount;

    // 풀이 스냅샷 JSON {isCorrect, attemptCount, solvedAt, topicCode, difficulty}, 없으면 null
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "JSONB")
    private String solveSnapshot;

    // 숨김·삭제 처리자 (AUTO_REPORT, 관리자 아이디, 본인 삭제는 null)
    @Column(length = 100)
    private String handledBy;

    public static CommunityPost createQuestionOpinion(UUID questionUuid, UUID authorMemberUuid, String content, String solveSnapshot) {
        CommunityPost post = new CommunityPost();
        post.boardType = CommunityBoardType.QUESTION_OPINION;
        post.targetType = CommunityTargetType.QUESTION;
        post.targetUuid = questionUuid;
        post.authorMemberUuid = authorMemberUuid;
        post.content = content;
        post.solveSnapshot = solveSnapshot;
        post.status = CommunityPostStatus.VISIBLE;
        post.likeCount = 0;
        post.commentCount = 0;
        post.reportCount = 0;
        return post;
    }

    public boolean isVisible() {
        return status == CommunityPostStatus.VISIBLE;
    }

    public boolean isAuthoredBy(UUID memberUuid) {
        return authorMemberUuid.equals(memberUuid);
    }

    public void hide(CommunityPostStatus hiddenStatus, String handledBy) {
        this.status = hiddenStatus;
        this.handledBy = handledBy;
    }

    public void restore() {
        this.status = CommunityPostStatus.VISIBLE;
        this.handledBy = null;
    }

    /** 삭제: 내용만 비우고 행은 유지 (신고·카운트 정합성) */
    public void markDeleted(String handledBy) {
        this.status = CommunityPostStatus.DELETED;
        this.content = "";
        this.solveSnapshot = null;
        this.handledBy = handledBy;
    }

    public void updateReportCount(int pendingReportCount) {
        this.reportCount = pendingReportCount;
    }
}
