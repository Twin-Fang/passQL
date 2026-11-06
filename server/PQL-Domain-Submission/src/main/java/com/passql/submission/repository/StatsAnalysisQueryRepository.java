package com.passql.submission.repository;

import com.passql.submission.entity.Submission;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

/**
 * 통계 AI 분석 조회 전용 (#861): 세부 주제별 정답률, 최근 오답 문제, 마지막 시도 오답 수, 2주 정답률
 * SubmissionRepository 400줄 초과라 분리. 네이티브 쿼리(Submission <-> Question 연관관계 없음), 문제별 마지막 시도 기준
 * uuid 목록은 CAST(... AS varchar) IN (문자열 목록) 비교 (QuestionRepository 와 같은 방식)
 */
public interface StatsAnalysisQueryRepository extends Repository<Submission, UUID> {

    /**
     * 토픽들의 세부 주제별 풀이 수·정답률 (since 이후, 문제별 마지막 시도, minSolvedCount 이상만)
     * Object[] = { UUID topicUuid, String topicName, String subtopicName, Number solvedCount, Number correctRate }
     */
    @Query(value = """
        WITH latest AS (
            SELECT q.topic_uuid, q.subtopic_uuid, s.is_correct,
                   ROW_NUMBER() OVER (PARTITION BY s.question_uuid ORDER BY s.submitted_at DESC, s.submission_uuid DESC) AS rn
            FROM submission s
            JOIN question q ON q.question_uuid = s.question_uuid
            WHERE s.member_uuid = CAST(:memberUuid AS uuid)
              AND s.submitted_at >= :since
              AND CAST(q.topic_uuid AS varchar) IN (:topicUuids)
        )
        SELECT l.topic_uuid, t.display_name AS topic_name, st.display_name AS subtopic_name,
               COUNT(*) AS solved_count,
               AVG(CASE WHEN l.is_correct = true THEN 1.0 ELSE 0.0 END) AS correct_rate
        FROM latest l
        JOIN topic t ON t.topic_uuid = l.topic_uuid
        JOIN subtopic st ON st.subtopic_uuid = l.subtopic_uuid
        WHERE l.rn = 1
        GROUP BY l.topic_uuid, t.display_name, st.display_name, st.sort_order
        HAVING COUNT(*) >= :minSolvedCount
        ORDER BY st.sort_order ASC
        """, nativeQuery = true)
    List<Object[]> findSubtopicStatsAfter(@Param("memberUuid") String memberUuid,
                                          @Param("since") LocalDateTime since,
                                          @Param("topicUuids") Collection<String> topicUuids,
                                          @Param("minSolvedCount") int minSolvedCount);

    /**
     * 토픽들에서 마지막 시도가 오답인 활성 문제 (최근 순, limit 건)
     * Object[] = { String topicName, String subtopicName(null 가능), String stem }
     */
    @Query(value = """
        WITH latest AS (
            SELECT s.question_uuid, s.is_correct, s.submitted_at,
                   ROW_NUMBER() OVER (PARTITION BY s.question_uuid ORDER BY s.submitted_at DESC, s.submission_uuid DESC) AS rn
            FROM submission s
            WHERE s.member_uuid = CAST(:memberUuid AS uuid)
        )
        SELECT t.display_name AS topic_name, st.display_name AS subtopic_name, q.stem
        FROM latest l
        JOIN question q ON q.question_uuid = l.question_uuid
        JOIN topic t ON t.topic_uuid = q.topic_uuid
        LEFT JOIN subtopic st ON st.subtopic_uuid = q.subtopic_uuid
        WHERE l.rn = 1
          AND l.is_correct = false
          AND q.is_active = true
          AND CAST(q.topic_uuid AS varchar) IN (:topicUuids)
        ORDER BY l.submitted_at DESC
        LIMIT :limit
        """, nativeQuery = true)
    List<Object[]> findRecentLatestWrongQuestions(@Param("memberUuid") String memberUuid,
                                                  @Param("topicUuids") Collection<String> topicUuids,
                                                  @Param("limit") int limit);

    /** 마지막 시도가 오답인 활성 문제 수 (오답 다시 풀기 버튼 판정) */
    @Query(value = """
        WITH latest AS (
            SELECT s.question_uuid, s.is_correct,
                   ROW_NUMBER() OVER (PARTITION BY s.question_uuid ORDER BY s.submitted_at DESC, s.submission_uuid DESC) AS rn
            FROM submission s
            WHERE s.member_uuid = CAST(:memberUuid AS uuid)
        )
        SELECT COUNT(*)
        FROM latest l
        JOIN question q ON q.question_uuid = l.question_uuid
        WHERE l.rn = 1 AND l.is_correct = false AND q.is_active = true
        """, nativeQuery = true)
    long countLatestWrongQuestions(@Param("memberUuid") String memberUuid);

    /**
     * 2주 제출 집계: 이번 주 [thisWeekStart, 지금), 지난주 [lastWeekStart, thisWeekStart)
     * Object[] = { Number thisWeekCount, Number thisWeekCorrect, Number lastWeekCount, Number lastWeekCorrect }
     */
    @Query(value = """
        SELECT COALESCE(SUM(CASE WHEN s.submitted_at >= :thisWeekStart THEN 1 ELSE 0 END), 0),
               COALESCE(SUM(CASE WHEN s.submitted_at >= :thisWeekStart AND s.is_correct = true THEN 1 ELSE 0 END), 0),
               COALESCE(SUM(CASE WHEN s.submitted_at < :thisWeekStart THEN 1 ELSE 0 END), 0),
               COALESCE(SUM(CASE WHEN s.submitted_at < :thisWeekStart AND s.is_correct = true THEN 1 ELSE 0 END), 0)
        FROM submission s
        WHERE s.member_uuid = CAST(:memberUuid AS uuid)
          AND s.submitted_at >= :lastWeekStart
        """, nativeQuery = true)
    List<Object[]> findTwoWeekSubmissionCounts(@Param("memberUuid") String memberUuid,
                                               @Param("thisWeekStart") LocalDateTime thisWeekStart,
                                               @Param("lastWeekStart") LocalDateTime lastWeekStart);
}
