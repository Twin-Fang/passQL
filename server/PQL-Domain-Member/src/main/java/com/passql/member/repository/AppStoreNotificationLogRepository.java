package com.passql.member.repository;

import com.passql.member.entity.AppStoreNotificationLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

/** App Store 서버 알림 수신 기록 (#1032) */
public interface AppStoreNotificationLogRepository extends JpaRepository<AppStoreNotificationLog, UUID> {

    /** 최신 수신순 목록 (관리자 화면, 정렬은 pageable) */
    Page<AppStoreNotificationLog> findAll(Pageable pageable);

    /** 거래 ID 목록의 알림 기록 (결제 목록 환불 요청 배지 판정) */
    List<AppStoreNotificationLog> findByTransactionIdInOrderByReceivedAtAsc(Collection<String> transactionIds);
}
