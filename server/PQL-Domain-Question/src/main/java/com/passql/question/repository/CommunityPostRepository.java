package com.passql.question.repository;

import com.passql.question.entity.CommunityPost;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface CommunityPostRepository extends JpaRepository<CommunityPost, UUID> {

    // 문제별 의견 목록 공통 조건: 노출 중 + 보는 회원이 차단한 작성자 제외
    String VISIBLE_QUESTION_OPINION_FOR_VIEWER = """
            p.boardType = 'QUESTION_OPINION' AND p.targetType = 'QUESTION' AND p.targetUuid = :questionUuid
            AND p.status = 'VISIBLE'
            AND p.authorMemberUuid NOT IN (SELECT b.blockedMemberUuid FROM MemberBlock b WHERE b.blockerMemberUuid = :viewerUuid)
            """;

    /** 최신순 키셋 페이지 (첫 페이지는 미래 시각 센티넬) */
    @Query("SELECT p FROM CommunityPost p WHERE " + VISIBLE_QUESTION_OPINION_FOR_VIEWER + """
            AND (p.createdAt < :cursorCreatedAt OR (p.createdAt = :cursorCreatedAt AND p.postUuid < :cursorPostUuid))
            ORDER BY p.createdAt DESC, p.postUuid DESC
            """)
    List<CommunityPost> findLatestPage(@Param("questionUuid") UUID questionUuid, @Param("viewerUuid") UUID viewerUuid,
                                       @Param("cursorCreatedAt") LocalDateTime cursorCreatedAt,
                                       @Param("cursorPostUuid") UUID cursorPostUuid, Pageable pageable);

    /** 좋아요순 키셋 페이지 (좋아요 많은 순 > 최신순, 첫 페이지는 최댓값 센티넬) */
    @Query("SELECT p FROM CommunityPost p WHERE " + VISIBLE_QUESTION_OPINION_FOR_VIEWER + """
            AND (p.likeCount < :cursorLikeCount
                 OR (p.likeCount = :cursorLikeCount AND (p.createdAt < :cursorCreatedAt
                     OR (p.createdAt = :cursorCreatedAt AND p.postUuid < :cursorPostUuid))))
            ORDER BY p.likeCount DESC, p.createdAt DESC, p.postUuid DESC
            """)
    List<CommunityPost> findLikesPage(@Param("questionUuid") UUID questionUuid, @Param("viewerUuid") UUID viewerUuid,
                                      @Param("cursorLikeCount") int cursorLikeCount,
                                      @Param("cursorCreatedAt") LocalDateTime cursorCreatedAt,
                                      @Param("cursorPostUuid") UUID cursorPostUuid, Pageable pageable);

    /** 피드 집계 원본: 문제별 노출 중 의견 수·좋아요 합·최근 글 시각 */
    @Query("""
            SELECT p.targetUuid AS questionUuid, COUNT(p) AS postCount, COALESCE(SUM(p.likeCount), 0) AS likeCount,
                   MAX(p.createdAt) AS lastPostedAt
            FROM CommunityPost p
            WHERE p.boardType = 'QUESTION_OPINION' AND p.targetType = 'QUESTION' AND p.status = 'VISIBLE'
            GROUP BY p.targetUuid
            """)
    List<QuestionPostAggregate> aggregateVisibleByQuestion();

    /** 피드 '내 의견': 내가 쓴 노출 글을 문제별로 (최근 작성순) */
    @Query("""
            SELECT p.targetUuid AS questionUuid, COUNT(p) AS postCount, COALESCE(SUM(p.likeCount), 0) AS likeCount,
                   MAX(p.createdAt) AS lastPostedAt
            FROM CommunityPost p
            WHERE p.boardType = 'QUESTION_OPINION' AND p.targetType = 'QUESTION' AND p.status = 'VISIBLE'
              AND p.authorMemberUuid = :memberUuid
            GROUP BY p.targetUuid
            ORDER BY MAX(p.createdAt) DESC
            """)
    List<QuestionPostAggregate> aggregateVisibleByQuestionOfAuthor(@Param("memberUuid") UUID memberUuid);

    /** 관리자 목록: 신고가 있거나 숨겨진 글 (삭제 제외) */
    @Query("SELECT p FROM CommunityPost p WHERE p.status <> 'DELETED' AND (p.reportCount > 0 OR p.status IN ('HIDDEN_AUTO', 'HIDDEN_ADMIN'))")
    Page<CommunityPost> findReportedOrHidden(Pageable pageable);

    /** 관리자 목록: 검토 대기 신고가 있는 글만 */
    @Query("SELECT p FROM CommunityPost p WHERE p.status <> 'DELETED' AND p.reportCount > 0")
    Page<CommunityPost> findWithPendingReports(Pageable pageable);

    @Query("SELECT COUNT(p) FROM CommunityPost p WHERE p.status <> 'DELETED' AND p.reportCount > 0")
    long countWithPendingReports();

    // 카운터는 동시 요청에도 어긋나지 않게 DB 에서 직접 증감 (0 미만 방지)
    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("UPDATE CommunityPost p SET p.likeCount = p.likeCount + 1 WHERE p.postUuid = :postUuid")
    int increaseLikeCount(@Param("postUuid") UUID postUuid);

    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("UPDATE CommunityPost p SET p.likeCount = CASE WHEN p.likeCount > 0 THEN p.likeCount - 1 ELSE 0 END WHERE p.postUuid = :postUuid")
    int decreaseLikeCount(@Param("postUuid") UUID postUuid);

    @Query("SELECT p.likeCount FROM CommunityPost p WHERE p.postUuid = :postUuid")
    int findLikeCount(@Param("postUuid") UUID postUuid);

    /** 하루 1회 보정: 좋아요 수를 실제 행 수로 */
    @Modifying
    @Query("""
            UPDATE CommunityPost p SET p.likeCount = (SELECT COUNT(l) FROM CommunityPostLike l WHERE l.postUuid = p.postUuid)
            WHERE p.likeCount <> (SELECT COUNT(l2) FROM CommunityPostLike l2 WHERE l2.postUuid = p.postUuid)
            """)
    int reconcileLikeCounts();

    /** 하루 1회 보정: 신고 수를 검토 대기 신고 행 수로 */
    @Modifying
    @Query("""
            UPDATE CommunityPost p SET p.reportCount =
                (SELECT COUNT(r) FROM CommunityReport r WHERE r.targetType = 'POST' AND r.targetUuid = p.postUuid AND r.status = 'PENDING')
            WHERE p.reportCount <>
                (SELECT COUNT(r2) FROM CommunityReport r2 WHERE r2.targetType = 'POST' AND r2.targetUuid = p.postUuid AND r2.status = 'PENDING')
            """)
    int reconcileReportCounts();

    List<CommunityPost> findAllByPostUuidIn(Collection<UUID> postUuids);
}
