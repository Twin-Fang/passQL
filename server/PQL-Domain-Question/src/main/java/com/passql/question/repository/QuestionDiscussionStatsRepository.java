package com.passql.question.repository;

import com.passql.question.entity.QuestionDiscussionStats;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface QuestionDiscussionStatsRepository extends JpaRepository<QuestionDiscussionStats, UUID> {

    /** 뜨는 토론: 최근 활동이 기준 시각 이후인 문제를 점수순 */
    @Query("""
            SELECT s FROM QuestionDiscussionStats s
            WHERE s.postCount > 0 AND s.lastActivityAt >= :activeSince
              AND s.questionUuid IN (SELECT q.questionUuid FROM Question q WHERE q.isActive = true)
            ORDER BY s.hotScore DESC, s.questionUuid DESC
            """)
    List<QuestionDiscussionStats> findHot(@Param("activeSince") LocalDateTime activeSince, Pageable pageable);

    /** 최신 경향 문제(#523) 중 의견이 있는 문제를 최근 활동순 */
    @Query("""
            SELECT s FROM QuestionDiscussionStats s
            WHERE s.postCount > 0
              AND s.questionUuid IN (SELECT q.questionUuid FROM Question q WHERE q.isActive = true AND q.isLatestTrend = true)
            ORDER BY s.lastActivityAt DESC, s.questionUuid DESC
            """)
    List<QuestionDiscussionStats> findLatestTrend(Pageable pageable);

    @Query("SELECT s FROM QuestionDiscussionStats s WHERE s.postCount > 0 AND s.questionUuid IN :questionUuids")
    List<QuestionDiscussionStats> findWithPostsByQuestionUuidIn(@Param("questionUuids") Collection<UUID> questionUuids);
}
