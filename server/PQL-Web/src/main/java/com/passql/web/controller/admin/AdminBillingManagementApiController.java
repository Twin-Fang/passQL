package com.passql.web.controller.admin;

import com.passql.application.billing.AppStoreRefundCheckOverview;
import com.passql.application.billing.AppStoreRefundCheckService;
import com.passql.application.billing.RefundCheckRunResponse;
import com.passql.application.billing.management.AdminPurchaseListService;
import com.passql.application.billing.management.AdminPurchasePageResponse;
import com.passql.application.billing.management.AdminPurchaseRevokeRequest;
import com.passql.application.billing.management.AdminPurchaseSearchCondition;
import com.passql.application.billing.management.AppStoreNotificationLogPageResponse;
import com.passql.application.billing.management.BillingPayoutResponse;
import com.passql.application.billing.management.BillingPayoutService;
import com.passql.application.billing.management.PayoutSettings;
import com.passql.application.entitlement.EntitlementPurchaseRevoker.RevocationResult;
import com.passql.member.constant.PurchaseStatus;
import com.passql.member.constant.PurchaseStore;
import com.passql.member.constant.RefundCheckTriggerType;
import com.passql.web.support.AdminBillingCsvExporter;
import com.passql.web.support.AdminPageRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.UUID;

/**
 * 관리자 결제 관리 API (#1032): 실수령액·설정, 전체 결제 목록·CSV·건별 회수, App Store 환불 점검, App Store 알림 수신 기록
 * 조회는 VIEWER 허용, 변경(PUT·POST)은 ADMIN 만 (AdminSecurityConfig)
 */
@RestController
@RequestMapping("/admin/api/subscriptions")
@RequiredArgsConstructor
public class AdminBillingManagementApiController implements AdminBillingManagementApiControllerDocs {

    // 알림 기록 정렬 기준 (수신 시각 최신순)
    private static final String NOTIFICATION_RECEIVED_AT_FIELD = "receivedAt";

    private final BillingPayoutService billingPayoutService;
    private final AdminPurchaseListService adminPurchaseListService;
    private final AppStoreRefundCheckService appStoreRefundCheckService;

    @GetMapping("/payout")
    public ResponseEntity<BillingPayoutResponse> getPayout(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return ResponseEntity.ok(billingPayoutService.getPayout(from, to));
    }

    @PutMapping("/payout/settings")
    public ResponseEntity<PayoutSettings> savePayoutSettings(@Valid @RequestBody PayoutSettings request) {
        return ResponseEntity.ok(billingPayoutService.saveSettings(request));
    }

    @GetMapping("/purchases")
    public ResponseEntity<AdminPurchasePageResponse> getPurchases(
            @RequestParam(required = false) PurchaseStore store,
            @RequestParam(required = false) PurchaseStatus status,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = AdminPageRequest.DEFAULT_PAGE_SIZE) int size) {
        var pageable = AdminPageRequest.newestFirst(page, size);
        return ResponseEntity.ok(adminPurchaseListService.getPurchasePage(
                new AdminPurchaseSearchCondition(store, status, from, to), pageable.getPageNumber(), pageable.getPageSize()));
    }

    @GetMapping("/purchases.csv")
    public ResponseEntity<byte[]> exportPurchasesCsv(
            @RequestParam(required = false) PurchaseStore store,
            @RequestParam(required = false) PurchaseStatus status,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return AdminBillingCsvExporter.purchases(adminPurchaseListService.getPurchasesForCsv(
                new AdminPurchaseSearchCondition(store, status, from, to)));
    }

    @PostMapping("/purchases/{entitlementPurchaseUuid}/revoke")
    public ResponseEntity<RevocationResult> revokePurchase(@PathVariable UUID entitlementPurchaseUuid,
                                                           @Valid @RequestBody AdminPurchaseRevokeRequest request) {
        return ResponseEntity.ok(adminPurchaseListService.revokePurchase(entitlementPurchaseUuid, request));
    }

    @GetMapping("/app-store/refund-checks")
    public ResponseEntity<AppStoreRefundCheckOverview> getAppStoreRefundCheckOverview() {
        return ResponseEntity.ok(appStoreRefundCheckService.getOverview());
    }

    @PostMapping("/app-store/refund-checks")
    public ResponseEntity<RefundCheckRunResponse> runAppStoreRefundCheck() {
        return ResponseEntity.ok(appStoreRefundCheckService.runRefundCheck(RefundCheckTriggerType.ADMIN));
    }

    @GetMapping("/app-store/notifications")
    public ResponseEntity<AppStoreNotificationLogPageResponse> getAppStoreNotifications(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = AdminPageRequest.DEFAULT_PAGE_SIZE) int size) {
        return ResponseEntity.ok(adminPurchaseListService.getNotificationLogPage(
                AdminPageRequest.newestFirstBy(page, size, NOTIFICATION_RECEIVED_AT_FIELD)));
    }
}
