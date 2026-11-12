package com.passql.application.billing;

import com.passql.common.exception.CustomException;
import com.passql.common.util.ServiceTimeZone;
import com.passql.member.constant.AppStoreNotificationResult;
import com.passql.member.entity.AppStoreNotificationLog;
import com.passql.member.repository.AppStoreNotificationLogRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.Set;

/**
 * App Store 서버 알림 V2 처리 (#578, #1032): 서명 검증 > 유형별 처리 > 수신 기록 1행
 * REFUND·REVOKE 회수, CONSUMPTION_REQUEST 환불 요청 접수(설정 시 소비 정보 응답), 그 외 기록만
 * 기록 저장 실패는 알림 처리를 막지 않음, 검증 실패는 결과만 기록하고 400 그대로
 */
@Slf4j
@Service
public class AppStoreNotificationService {

    // 등급 회수 대상 알림 유형 2개: REFUND 환불, REVOKE 가족 공유 해제 등 회수
    static final Set<String> REVOKING_NOTIFICATION_TYPES = Set.of("REFUND", "REVOKE");
    // 환불 요청 접수 알림 (고객 환불 요청 > Apple 이 소비 정보 요청, 12시간 안 응답 시 환불 판단에 반영)
    public static final String CONSUMPTION_REQUEST_NOTIFICATION_TYPE = "CONSUMPTION_REQUEST";

    private final AppStoreSignedDataVerifier appStoreSignedDataVerifier;
    private final AppStoreBillingService appStoreBillingService;
    private final AppStoreConsumptionResponder appStoreConsumptionResponder;
    private final AppStoreNotificationLogRepository appStoreNotificationLogRepository;
    private final Clock clock;

    @Autowired
    public AppStoreNotificationService(AppStoreSignedDataVerifier appStoreSignedDataVerifier,
                                       AppStoreBillingService appStoreBillingService,
                                       AppStoreConsumptionResponder appStoreConsumptionResponder,
                                       AppStoreNotificationLogRepository appStoreNotificationLogRepository) {
        this.appStoreSignedDataVerifier = appStoreSignedDataVerifier;
        this.appStoreBillingService = appStoreBillingService;
        this.appStoreConsumptionResponder = appStoreConsumptionResponder;
        this.appStoreNotificationLogRepository = appStoreNotificationLogRepository;
        this.clock = Clock.system(ServiceTimeZone.ZONE);
    }

    /** 알림 1건: 서명 검증(실패 > 기록 후 400) > 유형별 처리 > 수신 기록 (Apple 재전송 안전) */
    public void handleNotification(AppStoreNotificationRequest request) {
        AppStoreNotification notification;
        try {
            notification = appStoreSignedDataVerifier.verifyNotification(request.signedPayload());
        } catch (CustomException exception) {
            recordSafely(null, AppStoreNotificationResult.VERIFICATION_FAILED);
            throw exception;
        }
        recordSafely(notification, handleVerifiedNotification(notification));
    }

    /** 유형별 처리 결과: 회수 유형 > 회수, 환불 요청 > 접수·소비 정보, 그 외 무시 */
    private AppStoreNotificationResult handleVerifiedNotification(AppStoreNotification notification) {
        String notificationType = notification.notificationType();
        if (CONSUMPTION_REQUEST_NOTIFICATION_TYPE.equals(notificationType)) {
            return appStoreConsumptionResponder.respond(notification.transaction());
        }
        if (!REVOKING_NOTIFICATION_TYPES.contains(notificationType)) {
            log.info("[billing] app store notification ignored : type={}, subtype={}, notification={}",
                notificationType, notification.subtype(), notification.notificationUuid());
            return AppStoreNotificationResult.IGNORED;
        }
        if (notification.transaction() == null) {
            log.warn("[billing] app store notification ignored : type={}, no transaction, notification={}",
                notificationType, notification.notificationUuid());
            return AppStoreNotificationResult.IGNORED;
        }
        String transactionId = notification.transaction().transactionId();
        if (appStoreBillingService.revokeVerifiedPurchase(transactionId)) {
            return AppStoreNotificationResult.REVOKED;
        }
        log.info("[billing] app store notification ignored : type={}, transaction={}, no verified purchase",
            notificationType, transactionId);
        return AppStoreNotificationResult.NO_VERIFIED_PURCHASE;
    }

    /** 수신 기록 1행 (검증 실패는 알림 값 없이 결과만, 저장 실패는 로그만) */
    private void recordSafely(AppStoreNotification notification, AppStoreNotificationResult handlingResult) {
        try {
            AppStoreTransaction transaction = notification == null ? null : notification.transaction();
            appStoreNotificationLogRepository.save(AppStoreNotificationLog.of(
                notification == null ? null : notification.notificationUuid(),
                notification == null ? null : notification.notificationType(),
                notification == null ? null : notification.subtype(),
                transaction == null ? null : transaction.transactionId(),
                transaction == null ? null : transaction.environment(),
                handlingResult, LocalDateTime.now(clock)));
        } catch (RuntimeException exception) {
            log.warn("[billing] app store notification log failed : cause={}", exception.getClass().getSimpleName());
        }
    }
}
