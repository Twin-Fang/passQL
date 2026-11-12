package com.passql.member.repository;

import com.passql.member.entity.BillingRefundCheckRun;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/** Play 환불 회수 확인 실행 기록 (#984) */
public interface BillingRefundCheckRunRepository extends JpaRepository<BillingRefundCheckRun, UUID> {

    /** 최근 실행 기록 (시작 시각 내림차순, 개수는 pageable) */
    List<BillingRefundCheckRun> findAllByOrderByStartedAtDesc(Pageable pageable);

    /** 가장 최근 실행 1건 */
    Optional<BillingRefundCheckRun> findFirstByOrderByStartedAtDesc();

    /** startedAt 이후 성공(실패 사유 없음) 실행 존재 여부 */
    boolean existsByFailureReasonIsNullAndStartedAtAfter(LocalDateTime startedAt);
}
