package com.passql.question.repository;

import com.passql.question.constant.EmbeddingIndexRunStatus;
import com.passql.question.entity.EmbeddingIndexRun;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface EmbeddingIndexRunRepository extends JpaRepository<EmbeddingIndexRun, UUID> {

    /** 최근 실행 (시작 시각 내림차순) */
    List<EmbeddingIndexRun> findAllByOrderByStartedAtDesc(Pageable pageable);

    /** 끝난 실행 중 가장 최근 1건 (실패 목록·마지막 실행 시각 기준) */
    Optional<EmbeddingIndexRun> findFirstByStatusNotOrderByStartedAtDesc(EmbeddingIndexRunStatus status);

    List<EmbeddingIndexRun> findByStatus(EmbeddingIndexRunStatus status);
}
