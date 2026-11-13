package com.passql.member.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.member.constant.AppStoreNotificationResult;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * App Store 서버 알림 수신 기록 1건 (#1032): 유형·하위 유형·알림 ID·거래 ID·환경·처리 결과·수신 시각
 * 서명 원문(JWS)·회원 개인정보는 저장하지 않음, 검증 실패는 알림 ID·유형 없이 결과만
 */
@Entity
@Table(name = "app_store_notification_log", indexes = {
    @Index(name = "idx_app_store_notification_log_received_at", columnList = "received_at"),
    @Index(name = "idx_app_store_notification_log_transaction_id", columnList = "transaction_id")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AppStoreNotificationLog extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID appStoreNotificationLogUuid;

    // Apple notificationUUID (재전송 시 같은 값, 검증 실패면 null)
    @Column(length = 64)
    private String notificationUuid;

    // 알림 유형 원문 (예: REFUND, CONSUMPTION_REQUEST, 검증 실패면 null)
    @Column(length = 50)
    private String notificationType;

    @Column(length = 50)
    private String subtype;

    // 알림에 담긴 거래 ID (거래 없는 알림·검증 실패면 null)
    @Column(length = 100)
    private String transactionId;

    // 거래 환경 원문 (Production, Sandbox)
    @Column(length = 20)
    private String environment;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private AppStoreNotificationResult handlingResult;

    @Column(nullable = false)
    private LocalDateTime receivedAt;

    /** 수신 기록 생성 (검증 실패는 알림 값 모두 null) */
    public static AppStoreNotificationLog of(String notificationUuid, String notificationType, String subtype,
                                             String transactionId, String environment,
                                             AppStoreNotificationResult handlingResult, LocalDateTime receivedAt) {
        AppStoreNotificationLog notificationLog = new AppStoreNotificationLog();
        notificationLog.notificationUuid = notificationUuid;
        notificationLog.notificationType = notificationType;
        notificationLog.subtype = subtype;
        notificationLog.transactionId = transactionId;
        notificationLog.environment = environment;
        notificationLog.handlingResult = handlingResult;
        notificationLog.receivedAt = receivedAt;
        return notificationLog;
    }
}
