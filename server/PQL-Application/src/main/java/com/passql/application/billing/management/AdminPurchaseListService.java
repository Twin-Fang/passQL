package com.passql.application.billing.management;

import com.passql.application.billing.AppStoreNotificationService;
import com.passql.application.billing.management.AdminPurchaseQueryRepository.PurchaseRow;
import com.passql.application.entitlement.EntitlementAdminService;
import com.passql.application.entitlement.EntitlementPurchaseRevoker.RevocationResult;
import com.passql.member.constant.PurchaseStatus;
import com.passql.member.constant.PurchaseStore;
import com.passql.member.entity.AppStoreNotificationLog;
import com.passql.member.repository.AppStoreNotificationLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 관리자 결제 목록·알림 기록 (#1032): 필터 조회(페이지·CSV) > App Store 환불 요청 상태 붙임 > 주문 번호 가림, 건별 회수는 회원 상세 회수 경로 재사용
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminPurchaseListService {

    // CSV 최대 행 수 (전체 내보내기 상한)
    public static final int MAXIMUM_CSV_ROW_COUNT = 10_000;
    // 주문 번호 앞뒤로 보여 줄 글자 수 (가운데는 *)
    static final int VISIBLE_ORDER_ID_EDGE_LENGTH = 4;
    // 환불 요청 상태: 요청 중, 거절됨
    static final String REFUND_REQUEST_STATE_REQUESTED = "REQUESTED";
    static final String REFUND_REQUEST_STATE_DECLINED = "DECLINED";
    // 환불 요청 상태를 끝내는 알림 유형: REFUND 환불, REFUND_DECLINED 거절, REFUND_REVERSED 환불 취소
    private static final String REFUND_DECLINED_NOTIFICATION_TYPE = "REFUND_DECLINED";
    private static final Set<String> REFUND_CLOSING_NOTIFICATION_TYPES = Set.of("REFUND", REFUND_DECLINED_NOTIFICATION_TYPE, "REFUND_REVERSED");
    // 금액 micros > 통화 단위
    private static final double MICROS_PER_CURRENCY_UNIT = 1_000_000d;

    private final AdminPurchaseQueryRepository adminPurchaseQueryRepository;
    private final AppStoreNotificationLogRepository appStoreNotificationLogRepository;
    private final EntitlementAdminService entitlementAdminService;

    /** 결제 목록 한 페이지 (page 0부터, size 는 호출자가 보정) */
    public AdminPurchasePageResponse getPurchasePage(AdminPurchaseSearchCondition condition, int page, int size) {
        long totalCount = adminPurchaseQueryRepository.countPurchases(condition);
        List<PurchaseRow> purchaseRows = adminPurchaseQueryRepository.findPurchases(condition, (long) page * size, size);
        int totalPageCount = (int) ((totalCount + size - 1) / size);
        return new AdminPurchasePageResponse(toRowResponses(purchaseRows), page, size, totalCount, totalPageCount);
    }

    /** CSV 행 (조건 전체, 최대 10,000건) */
    public List<AdminPurchaseRowResponse> getPurchasesForCsv(AdminPurchaseSearchCondition condition) {
        return toRowResponses(adminPurchaseQueryRepository.findPurchases(condition, 0, MAXIMUM_CSV_ROW_COUNT));
    }

    /** 건별 회수: 회원 상세 회수와 같은 경로 (사유·소유·검증 상태 확인, 등급 재계산, 감사 기록) */
    @Transactional
    public RevocationResult revokePurchase(UUID entitlementPurchaseUuid, AdminPurchaseRevokeRequest request) {
        return entitlementAdminService.revokePurchase(request.memberUuid(), entitlementPurchaseUuid, request.reason());
    }

    /** App Store 알림 수신 기록 한 페이지 (정렬은 pageable) */
    public AppStoreNotificationLogPageResponse getNotificationLogPage(Pageable pageable) {
        Page<AppStoreNotificationLog> logPage = appStoreNotificationLogRepository.findAll(pageable);
        return new AppStoreNotificationLogPageResponse(
            logPage.getContent().stream().map(AppStoreNotificationLogResponse::from).toList(),
            logPage.getNumber(), logPage.getSize(), logPage.getTotalElements(), logPage.getTotalPages());
    }

    /** 원본 행 > 응답 (App Store 거래는 알림 기록으로 환불 요청 상태 판정) */
    private List<AdminPurchaseRowResponse> toRowResponses(List<PurchaseRow> purchaseRows) {
        Map<String, String> refundRequestStateByTransactionId = findRefundRequestStates(purchaseRows);
        return purchaseRows.stream().map(row -> new AdminPurchaseRowResponse(row.entitlementPurchaseUuid(),
            row.memberUuid(), row.memberNickname(), row.isTestAccount(), PurchaseStore.valueOf(row.store()),
            row.productId(), PurchaseStatus.valueOf(row.status()),
            row.priceAmountMicros() == null ? null : row.priceAmountMicros() / MICROS_PER_CURRENCY_UNIT,
            row.currencyCode(), row.purchasedAt(), row.grantedExpiresAt(), row.revokedAt(), maskOrderId(row.orderId()),
            PurchaseStatus.REVOKED.name().equals(row.status()) ? null : refundRequestStateByTransactionId.get(row.orderId())))
            .toList();
    }

    /**
     * App Store 거래 ID별 환불 요청 상태: 수신순 마지막 환불 관련 알림 기준
     * 환불 요청(CONSUMPTION_REQUEST) > REQUESTED, REFUND_DECLINED > DECLINED, REFUND·REFUND_REVERSED > 없음
     */
    private Map<String, String> findRefundRequestStates(List<PurchaseRow> purchaseRows) {
        Set<String> transactionIds = purchaseRows.stream()
            .filter(row -> PurchaseStore.APP_STORE.name().equals(row.store()))
            .map(PurchaseRow::orderId)
            .collect(Collectors.toSet());
        Map<String, String> stateByTransactionId = new HashMap<>();
        if (transactionIds.isEmpty()) {
            return stateByTransactionId;
        }
        for (AppStoreNotificationLog notificationLog : appStoreNotificationLogRepository
            .findByTransactionIdInOrderByReceivedAtAsc(transactionIds)) {
            String notificationType = notificationLog.getNotificationType();
            if (AppStoreNotificationService.CONSUMPTION_REQUEST_NOTIFICATION_TYPE.equals(notificationType)) {
                stateByTransactionId.put(notificationLog.getTransactionId(), REFUND_REQUEST_STATE_REQUESTED);
            } else if (REFUND_DECLINED_NOTIFICATION_TYPE.equals(notificationType)) {
                stateByTransactionId.put(notificationLog.getTransactionId(), REFUND_REQUEST_STATE_DECLINED);
            } else if (REFUND_CLOSING_NOTIFICATION_TYPES.contains(notificationType)) {
                stateByTransactionId.remove(notificationLog.getTransactionId());
            }
        }
        return stateByTransactionId;
    }

    /** 주문 번호 가운데 가림: 앞 4 + * + 뒤 4 (9자 이하는 앞 2자만) */
    static String maskOrderId(String orderId) {
        if (orderId == null || orderId.isEmpty()) {
            return "";
        }
        if (orderId.length() <= VISIBLE_ORDER_ID_EDGE_LENGTH * 2 + 1) {
            return orderId.substring(0, Math.min(2, orderId.length())) + "***";
        }
        return orderId.substring(0, VISIBLE_ORDER_ID_EDGE_LENGTH) + "****"
            + orderId.substring(orderId.length() - VISIBLE_ORDER_ID_EDGE_LENGTH);
    }
}
