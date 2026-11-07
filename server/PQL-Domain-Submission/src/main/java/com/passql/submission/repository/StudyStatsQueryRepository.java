package com.passql.submission.repository;

import com.passql.submission.dto.RecentAttemptProjection;
import com.passql.submission.entity.Submission;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * 학습 통계 조회 전용 (#909): 기간 안 제출 시각·정답 여부, 전체 제출과 문제 난이도·활성 여부
 * 집계는 StudyPatternCalculator·AccuracyDetailCalculator 가 맡고 여기서는 행만 읽음
 */
public interface StudyStatsQueryRepository extends Repository<Submission, UUID> {

    /** since 이후 제출 (요일·시간대·날짜별 집계용) */
    @Query("SELECT new com.passql.submission.dto.RecentAttemptProjection(s.isCorrect, s.submittedAt) " +
           "FROM Submission s " +
           "WHERE s.memberUuid = :memberUuid AND s.submittedAt >= :since")
    List<RecentAttemptProjection> findAttemptsSince(@Param("memberUuid") UUID memberUuid,
                                                    @Param("since") LocalDateTime since);

    /**
     * 전체 제출 시간순 + 문제 난이도·활성 여부 (난이도별 정답률·오답 추이용, 네이티브: Submission <-> Question 연관관계 없음)
     * Object[] = { String questionUuid, Boolean isCorrect, Timestamp submittedAt, Number difficulty, Boolean isActive }
     */
    @Query(value = """
        SELECT CAST(s.question_uuid AS varchar), s.is_correct, s.submitted_at, q.difficulty, q.is_active
        FROM submission s
        JOIN question q ON q.question_uuid = s.question_uuid
        WHERE s.member_uuid = CAST(:memberUuid AS uuid)
        ORDER BY s.submitted_at ASC, s.submission_uuid ASC
        """, nativeQuery = true)
    List<Object[]> findQuestionAttemptRows(@Param("memberUuid") String memberUuid);
}
