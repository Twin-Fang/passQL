package com.passql.meta.repository;

import com.passql.meta.entity.ServerErrorLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface ServerErrorLogRepository extends JpaRepository<ServerErrorLog, UUID> {

    List<ServerErrorLog> findTop50ByOrderByOccurredAtDesc();

    long countByOccurredAtAfter(LocalDateTime since);

    // 행 단위 삭제(deleteBy…)는 건마다 select 후 delete 라 오래된 행이 많으면 느리다 — 한 번에 지운다
    @Modifying
    @Query("delete from ServerErrorLog e where e.occurredAt < :before")
    int deleteOlderThan(LocalDateTime before);
}
