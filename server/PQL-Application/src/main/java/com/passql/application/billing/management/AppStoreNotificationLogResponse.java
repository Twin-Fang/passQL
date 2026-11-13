package com.passql.application.billing.management;

import com.passql.member.constant.AppStoreNotificationResult;
import com.passql.member.entity.AppStoreNotificationLog;

import java.time.LocalDateTime;

/**
 * App Store 알림 수신 기록 1행 (#1032): 유형·하위 유형·알림 ID·거래 ID(결제 목록과 같은 가림)·환경·처리 결과·수신 시각
 * isRefundRequest: 환불 요청(CONSUMPTION_REQUEST) 접수 건 (화면 강조)
 */
public record AppStoreNotificationLogResponse(
    String notificationUuid,
    String notificationType,
    String subtype,
    String transactionId,
    String environment,
    AppStoreNotificationResult handlingResult,
    String handlingResultLabel,
    Boolean isRefundRequest,
    LocalDateTime receivedAt) {

    /** 기록 엔티티 > 응답 */
    static AppStoreNotificationLogResponse from(AppStoreNotificationLog notificationLog) {
        AppStoreNotificationResult handlingResult = notificationLog.getHandlingResult();
        return new AppStoreNotificationLogResponse(notificationLog.getNotificationUuid(),
            notificationLog.getNotificationType(), notificationLog.getSubtype(),
            AdminPurchaseListService.maskOrderId(notificationLog.getTransactionId()),
            notificationLog.getEnvironment(), handlingResult, handlingResult.getLabel(), handlingResult.isRefundRequest(),
            notificationLog.getReceivedAt());
    }
}
