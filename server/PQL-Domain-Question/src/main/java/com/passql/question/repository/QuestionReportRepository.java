package com.passql.question.repository;

import com.passql.question.constant.ReportStatus;
import com.passql.question.entity.QuestionReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface QuestionReportRepository extends JpaRepository<QuestionReport, UUID> {

    boolean existsByMemberUuidAndSubmissionUuid(UUID memberUuid, UUID submissionUuid);

    boolean existsByQuestionUuidAndMemberUuidAndSubmissionUuid(UUID questionUuid, UUID memberUuid, UUID submissionUuid);

    List<QuestionReport> findByQuestionUuidOrderByCreatedAtDesc(UUID questionUuid);

    long countByStatus(ReportStatus status);

    /**
     * 문제별 집계: 상태 목록·기간(createdAt >= from, < to)으로 거른 신고를 문제 단위로 묶음
     * pendingCount 는 필터 범위 안의 PENDING 수 (RESOLVED 필터면 항상 0)
     * 열: questionUuid, totalCount, pendingCount, latestReportedAt
     */
    @Query("""
            SELECT r.questionUuid, COUNT(r),
                   SUM(CASE WHEN r.status = com.passql.question.constant.ReportStatus.PENDING THEN 1 ELSE 0 END),
                   MAX(r.createdAt)
            FROM QuestionReport r
            WHERE r.status IN :statuses AND r.createdAt >= :fromAt AND r.createdAt < :toAt
            GROUP BY r.questionUuid
            """)
    List<Object[]> findReportSummaryGroupByQuestion(@Param("statuses") Collection<ReportStatus> statuses,
                                                    @Param("fromAt") LocalDateTime fromAt,
                                                    @Param("toAt") LocalDateTime toAt);

    /** 문제·카테고리별 신고 수 (같은 필터, 신고 1건이 여러 카테고리면 각각 1로 셈). 열: questionUuid, category, count */
    @Query("""
            SELECT r.questionUuid, c, COUNT(r)
            FROM QuestionReport r JOIN r.categories c
            WHERE r.status IN :statuses AND r.createdAt >= :fromAt AND r.createdAt < :toAt
            GROUP BY r.questionUuid, c
            """)
    List<Object[]> findCategoryCountGroupByQuestion(@Param("statuses") Collection<ReportStatus> statuses,
                                                    @Param("fromAt") LocalDateTime fromAt,
                                                    @Param("toAt") LocalDateTime toAt);

    /** 일괄 처리용: 신고 UUID 목록 */
    List<QuestionReport> findByQuestionReportUuidIn(Collection<UUID> questionReportUuids);
}
