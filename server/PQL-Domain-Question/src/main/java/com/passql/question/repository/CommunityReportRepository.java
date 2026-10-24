package com.passql.question.repository;

import com.passql.question.constant.CommunityReportStatus;
import com.passql.question.constant.CommunityReportTargetType;
import com.passql.question.entity.CommunityReport;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface CommunityReportRepository extends JpaRepository<CommunityReport, UUID> {

    boolean existsByTargetTypeAndTargetUuidAndReporterMemberUuid(CommunityReportTargetType targetType, UUID targetUuid,
                                                                  UUID reporterMemberUuid);

    long countByTargetTypeAndTargetUuidAndStatus(CommunityReportTargetType targetType, UUID targetUuid,
                                                 CommunityReportStatus status);

    List<CommunityReport> findByTargetTypeAndTargetUuidOrderByCreatedAtDesc(CommunityReportTargetType targetType, UUID targetUuid);

    /** 관리자 목록: 여러 대상의 신고를 한 번에 */
    List<CommunityReport> findByTargetTypeAndTargetUuidInOrderByCreatedAtDesc(CommunityReportTargetType targetType,
                                                                              java.util.Collection<UUID> targetUuids);

    /** 관리자 처리: 검토 대기 신고를 한 번에 처리 완료·기각으로 바꾸고 처리 기록 남김 */
    @Modifying(flushAutomatically = true)
    @Query("""
            UPDATE CommunityReport r SET r.status = :toStatus, r.handledBy = :handledBy,
                r.handledNote = :handledNote, r.handledAt = :handledAt
            WHERE r.targetType = 'POST' AND r.targetUuid = :postUuid AND r.status = 'PENDING'
            """)
    int closePendingPostReports(@Param("postUuid") UUID postUuid, @Param("toStatus") CommunityReportStatus toStatus,
                                @Param("handledBy") String handledBy, @Param("handledNote") String handledNote,
                                @Param("handledAt") LocalDateTime handledAt);

    /** 관리자 회원 상세: 이 회원이 한 신고 (최신순) */
    List<CommunityReport> findByReporterMemberUuidOrderByCreatedAtDesc(UUID reporterMemberUuid, Pageable pageable);

    long countByStatus(CommunityReportStatus status);

    /** 처리 통계: 기간 안에 처리된 신고의 상태별 건수 */
    @Query("SELECT r.status, COUNT(r) FROM CommunityReport r WHERE r.handledAt >= :since GROUP BY r.status")
    List<Object[]> countHandledSinceGroupByStatus(@Param("since") LocalDateTime since);

    /** 처리 통계: 기간 안에 처리된 신고의 접수 시각·처리 시각 (평균 처리 시간 계산용) */
    @Query("SELECT r.createdAt, r.handledAt FROM CommunityReport r WHERE r.handledAt >= :since")
    List<Object[]> findCreatedAndHandledTimesSince(@Param("since") LocalDateTime since);

    /** 탈퇴 정리 1단계: 이 회원의 검토 대기 글 신고만큼 글 신고 수 차감 */
    @Modifying
    @Query("""
            UPDATE CommunityPost p SET p.reportCount = CASE WHEN p.reportCount > 0 THEN p.reportCount - 1 ELSE 0 END
            WHERE p.postUuid IN (SELECT r.targetUuid FROM CommunityReport r
                WHERE r.reporterMemberUuid = :memberUuid AND r.targetType = 'POST' AND r.status = 'PENDING')
            """)
    int decreaseReportCountsOfMember(@Param("memberUuid") UUID memberUuid);

    /** 탈퇴 정리 2단계: 이 회원이 한 신고 삭제 */
    @Modifying
    @Query("DELETE FROM CommunityReport r WHERE r.reporterMemberUuid = :memberUuid")
    int deleteAllByReporter(@Param("memberUuid") UUID memberUuid);
}
