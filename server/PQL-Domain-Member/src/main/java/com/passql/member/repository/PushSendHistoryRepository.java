package com.passql.member.repository;

import com.passql.member.constant.PushDispatchStatus;
import com.passql.member.entity.PushSendHistory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface PushSendHistoryRepository extends JpaRepository<PushSendHistory, UUID>, JpaSpecificationExecutor<PushSendHistory> {

    Page<PushSendHistory> findAllByOrderBySentAtDesc(Pageable pageable);

    /** 발송 시각이 된 예약 (오래된 예약부터) */
    List<PushSendHistory> findAllByDispatchStatusAndScheduledAtLessThanEqualOrderByScheduledAtAsc(
            PushDispatchStatus dispatchStatus, LocalDateTime now);

    /** 예약 > 발송 시작 선점 (이미 선점·취소된 예약은 0행, 서버 여러 대여도 한 번만 발송) > 바뀐 행 수 */
    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("update PushSendHistory h set h.dispatchStatus = :dispatched, h.sentAt = :now "
            + "where h.pushSendHistoryUuid = :uuid and h.dispatchStatus = :scheduled")
    int claimScheduled(@Param("uuid") UUID pushSendHistoryUuid, @Param("scheduled") PushDispatchStatus scheduled,
                       @Param("dispatched") PushDispatchStatus dispatched, @Param("now") LocalDateTime now);

    /** 예약 > 취소 (이미 발송 시작·취소된 건은 0행) > 바뀐 행 수 */
    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("update PushSendHistory h set h.dispatchStatus = :canceled "
            + "where h.pushSendHistoryUuid = :uuid and h.dispatchStatus = :scheduled")
    int cancelScheduled(@Param("uuid") UUID pushSendHistoryUuid, @Param("scheduled") PushDispatchStatus scheduled,
                        @Param("canceled") PushDispatchStatus canceled);

    /** 기간 내 실제 발송(테스트·회수·예약 제외) 이력, 통계용 */
    @Query("select h from PushSendHistory h where h.dispatchStatus = :dispatched and h.isTest = false "
            + "and h.isRetracted = false and h.sentAt >= :since")
    List<PushSendHistory> findDispatchedSince(@Param("dispatched") PushDispatchStatus dispatched,
                                              @Param("since") LocalDateTime since);
}
