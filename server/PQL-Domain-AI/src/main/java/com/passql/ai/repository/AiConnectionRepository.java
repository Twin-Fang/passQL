package com.passql.ai.repository;

import com.passql.ai.entity.AiConnection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface AiConnectionRepository extends JpaRepository<AiConnection, UUID> {

    List<AiConnection> findAllByOrderByPriorityAscCreatedAtAsc();

    boolean existsByConnectionName(String connectionName);

    boolean existsByConnectionNameAndAiConnectionUuidNot(String connectionName, UUID aiConnectionUuid);

    /** 호출 결과 기록 (엔티티 조회 없이 1건 갱신, 호출 경로를 가볍게) */
    @Modifying
    @Query("UPDATE AiConnection c SET c.lastSuccessAt = :calledAt WHERE c.aiConnectionUuid = :uuid")
    int updateLastSuccess(@Param("uuid") UUID aiConnectionUuid, @Param("calledAt") LocalDateTime calledAt);

    @Modifying
    @Query("UPDATE AiConnection c SET c.lastFailureAt = :calledAt, c.lastErrorType = :errorType WHERE c.aiConnectionUuid = :uuid")
    int updateLastFailure(@Param("uuid") UUID aiConnectionUuid, @Param("calledAt") LocalDateTime calledAt,
                          @Param("errorType") String errorType);
}
