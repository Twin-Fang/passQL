package com.passql.question.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import lombok.Getter;
import org.hibernate.annotations.Immutable;
import org.hibernate.annotations.Subselect;
import org.hibernate.annotations.Synchronize;

import java.util.UUID;

/**
 * 문제별 품질 지표 읽기 전용 뷰: 풀이 수, 정답 수, 정답률(%), 신고 수, 처리 대기 신고 수
 * 문제 전체 대상 LEFT JOIN 집계라 풀이·신고가 없는 문제도 0으로 1행씩 존재 (집계 쿼리 단일 원본)
 */
@Entity
@Immutable
@Getter
@Subselect("""
        SELECT q.question_uuid AS question_uuid,
               COALESCE(s.solve_count, 0) AS solve_count,
               COALESCE(s.correct_count, 0) AS correct_count,
               CASE WHEN COALESCE(s.solve_count, 0) = 0 THEN NULL
                    ELSE CAST(100.0 * s.correct_count / s.solve_count AS DOUBLE PRECISION) END AS accuracy_percent,
               COALESCE(r.report_count, 0) AS report_count,
               COALESCE(r.pending_report_count, 0) AS pending_report_count
        FROM question q
        LEFT JOIN (SELECT question_uuid,
                          COUNT(*) AS solve_count,
                          SUM(CASE WHEN is_correct THEN 1 ELSE 0 END) AS correct_count
                   FROM submission GROUP BY question_uuid) s ON s.question_uuid = q.question_uuid
        LEFT JOIN (SELECT question_uuid,
                          COUNT(*) AS report_count,
                          SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END) AS pending_report_count
                   FROM question_report GROUP BY question_uuid) r ON r.question_uuid = q.question_uuid
        """)
@Synchronize({"question", "submission", "question_report"})
public class QuestionQualityStat {

    @Id
    private UUID questionUuid;

    private Long solveCount;

    private Long correctCount;

    // 풀이 0건이면 null
    private Double accuracyPercent;

    private Long reportCount;

    private Long pendingReportCount;
}
