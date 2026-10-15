package com.passql.ai.repository;

import com.passql.ai.entity.AiCallLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface AiCallLogRepository extends JpaRepository<AiCallLog, UUID> {

    /** 기간 집계 1행: [전체 수, 성공 수, 평균 지연, 최대 지연] */
    @Query("SELECT COUNT(a), SUM(CASE WHEN a.isSuccess = true THEN 1 ELSE 0 END), "
            + "AVG(a.latencyMilliseconds), MAX(a.latencyMilliseconds) "
            + "FROM AiCallLog a WHERE a.calledAt >= :since")
    List<Object[]> aggregateSince(@Param("since") LocalDateTime since);

    @Modifying
    @Query("DELETE FROM AiCallLog a WHERE a.calledAt < :cutoff")
    int deleteOlderThan(@Param("cutoff") LocalDateTime cutoff);
}
