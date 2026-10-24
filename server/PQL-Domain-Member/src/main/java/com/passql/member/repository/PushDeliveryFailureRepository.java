package com.passql.member.repository;

import com.passql.member.entity.PushDeliveryFailure;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PushDeliveryFailureRepository extends JpaRepository<PushDeliveryFailure, UUID> {

    /** 발송별 실패 기기 (최신 기록 먼저) */
    List<PushDeliveryFailure> findAllByPushSendHistoryUuidOrderByCreatedAtDesc(UUID pushSendHistoryUuid);
}
