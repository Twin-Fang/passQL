package com.passql.member.repository;

import com.passql.member.constant.PurchaseStore;
import com.passql.member.entity.BillingRefundCheckRun;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/** 스토어 환불 회수 확인 실행 기록 (Play #984, App Store #1032) */
public interface BillingRefundCheckRunRepository extends JpaRepository<BillingRefundCheckRun, UUID> {

    /** 스토어별 최근 실행 기록 (시작 시각 내림차순, 개수는 pageable) */
    List<BillingRefundCheckRun> findAllByStoreOrderByStartedAtDesc(PurchaseStore store, Pageable pageable);

    /** 스토어별 가장 최근 실행 1건 */
    Optional<BillingRefundCheckRun> findFirstByStoreOrderByStartedAtDesc(PurchaseStore store);

    /** 스토어별 startedAt 이후 성공(실패 사유 없음) 실행 존재 여부 */
    boolean existsByStoreAndFailureReasonIsNullAndStartedAtAfter(PurchaseStore store, LocalDateTime startedAt);
}
