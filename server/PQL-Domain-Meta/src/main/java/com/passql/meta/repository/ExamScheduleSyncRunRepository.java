package com.passql.meta.repository;

import com.passql.meta.entity.ExamScheduleSyncRun;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ExamScheduleSyncRunRepository extends JpaRepository<ExamScheduleSyncRun, UUID> {

    /** 마지막 시도 (성공·실패 공통) */
    Optional<ExamScheduleSyncRun> findFirstByOrderByStartedAtDesc();

    /** 마지막 성공 */
    Optional<ExamScheduleSyncRun> findFirstByIsSuccessTrueOrderByStartedAtDesc();

    /** 최근 시도 10건 (관리자 화면 이력) */
    List<ExamScheduleSyncRun> findTop10ByOrderByStartedAtDesc();

    /** 아직 알리지 않은 새 연도 공개 중 가장 최근 1건 (기준 시각 이후 수집분만) */
    Optional<ExamScheduleSyncRun> findFirstByIsSuccessTrueAndPublishedYearIsNotNullAndIsPublishAnnouncedFalseAndStartedAtAfterOrderByStartedAtDesc(
            LocalDateTime startedAfter);

    /** 트랜잭션 단위 수집 잠금 (블루-그린 동시 기동 시 한 서버만 반영, 커밋·롤백 때 자동 해제) */
    @Query(value = "SELECT pg_try_advisory_xact_lock(:lockKey)", nativeQuery = true)
    boolean tryAcquireTransactionLock(long lockKey);
}
