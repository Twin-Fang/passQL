package com.passql.submission.repository;

import com.passql.submission.entity.Submission;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

/**
 * 오답률 TOP 집계 전용 (#1080): 활성 문제별 회원 첫 제출 수·첫 제출 오답 수
 * 테스트 계정 제외, 순위·최소 응시 기준은 HardestQuestionRanker 가 맡음
 */
public interface HardestQuestionQueryRepository extends Repository<Submission, UUID> {

    /**
     * 첫 제출 = 회원·문제별 제출 시각 오름차순 1위 (같은 시각은 submission_uuid 오름차순)
     * Object[] = { String questionUuid, String topicName, String topicCode, Number attemptCount, Number wrongCount }
     */
    @Query(value = """
        WITH first_submission AS (
            SELECT s.question_uuid,
                   s.is_correct,
                   ROW_NUMBER() OVER (PARTITION BY s.question_uuid, s.member_uuid ORDER BY s.submitted_at ASC, s.submission_uuid ASC) AS attempt_order
            FROM submission s
            WHERE NOT EXISTS (SELECT 1 FROM member tm WHERE tm.member_uuid = s.member_uuid AND tm.is_test_account = TRUE)
        )
        SELECT CAST(f.question_uuid AS varchar),
               t.display_name,
               t.code,
               COUNT(*) AS attempt_count,
               SUM(CASE WHEN f.is_correct = false THEN 1 ELSE 0 END) AS wrong_count
        FROM first_submission f
        JOIN question q ON q.question_uuid = f.question_uuid
        LEFT JOIN topic t ON t.topic_uuid = q.topic_uuid
        WHERE f.attempt_order = 1
          AND q.is_active = true
        GROUP BY f.question_uuid, t.display_name, t.code
        """, nativeQuery = true)
    List<Object[]> findFirstAttemptStats();
}
