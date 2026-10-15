package com.passql.submission.repository;

import com.passql.submission.entity.ExecutionLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface ExecutionLogRepository extends JpaRepository<ExecutionLog, UUID> {

    List<ExecutionLog> findTop20ByOrderByExecutedAtDesc();

    /** 기간 집계 1행: [전체 수, 성공(OK) 수, 평균 소요 ms] (#475, 메모리 집계 대체) */
    @Query("SELECT COUNT(e), SUM(CASE WHEN e.status = 'OK' THEN 1 ELSE 0 END), AVG(e.elapsedMs) "
            + "FROM ExecutionLog e WHERE e.executedAt > :since")
    List<Object[]> aggregateSince(@Param("since") LocalDateTime since);

    List<ExecutionLog> findByMemberUuidOrderByExecutedAtDesc(UUID memberUuid);

    List<ExecutionLog> findByQuestionUuidOrderByExecutedAtDesc(UUID questionUuid);

    @Modifying
    @Transactional
    void deleteByQuestionUuid(UUID questionUuid);
}
