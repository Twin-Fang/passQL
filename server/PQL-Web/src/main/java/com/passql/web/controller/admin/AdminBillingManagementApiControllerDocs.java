package com.passql.web.controller.admin;

import com.passql.application.billing.AppStoreRefundCheckOverview;
import com.passql.application.billing.RefundCheckRunResponse;
import com.passql.application.billing.management.AdminPurchasePageResponse;
import com.passql.application.billing.management.AdminPurchaseRevokeRequest;
import com.passql.application.billing.management.AppStoreNotificationLogPageResponse;
import com.passql.application.billing.management.BillingPayoutResponse;
import com.passql.application.billing.management.PayoutSettings;
import com.passql.application.entitlement.EntitlementPurchaseRevoker.RevocationResult;
import com.passql.common.dto.Author;
import com.passql.member.constant.PurchaseStatus;
import com.passql.member.constant.PurchaseStore;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;

import java.time.LocalDate;
import java.util.UUID;

@Tag(name = "Admin - Billing Management", description = "관리자 결제 관리 (관리자 세션, 조회는 VIEWER 허용, 변경은 ADMIN)")
public interface AdminBillingManagementApiControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.11.12", author = Author.SUHSAECHAN, issueNumber = 1032, description = "실수령액 대시보드 API 추가"),
    })
    @Operation(summary = "실수령액", description = "from·to: yyyy-MM-dd (from 생략 = 전체, to 생략 = 오늘). 구매 시각 기준, 테스트 계정 제외. 판매 총액 − 환불 − 원화 부가세 − 스토어 수수료 = 예상 실수령, 통화·스토어·상품별, 원화 최근 12개월 추이, 금액 미확인 건수")
    ResponseEntity<BillingPayoutResponse> getPayout(LocalDate from, LocalDate to);

    @ApiLogs({
        @ApiLog(date = "2026.11.12", author = Author.SUHSAECHAN, issueNumber = 1032, description = "실수령액 설정(수수료율·부가세율) 저장 API 추가"),
    })
    @Operation(summary = "실수령액 설정 저장", description = "Play·App Store 수수료율, 원화 부가세율 (%, 0 ~ 100). app_setting 저장 경로(감사 로그 포함)")
    ResponseEntity<PayoutSettings> savePayoutSettings(PayoutSettings request);

    @ApiLogs({
        @ApiLog(date = "2026.11.12", author = Author.SUHSAECHAN, issueNumber = 1032, description = "전체 결제 목록 API 추가"),
    })
    @Operation(summary = "전체 결제 목록", description = "store(PLAY·APP_STORE)·status(VERIFIED·REVOKED)·from·to 필터, 최신 구매순 페이지. 주문 번호는 가운데 가림, App Store 거래는 환불 요청 상태(REQUESTED·DECLINED)")
    ResponseEntity<AdminPurchasePageResponse> getPurchases(PurchaseStore store, PurchaseStatus status, LocalDate from,
                                                           LocalDate to, int page, int size);

    @ApiLogs({
        @ApiLog(date = "2026.11.12", author = Author.SUHSAECHAN, issueNumber = 1032, description = "전체 결제 목록 CSV 내보내기 추가"),
    })
    @Operation(summary = "전체 결제 목록 CSV", description = "목록과 같은 필터, 최대 10,000건, BOM 포함 UTF-8")
    ResponseEntity<byte[]> exportPurchasesCsv(PurchaseStore store, PurchaseStatus status, LocalDate from, LocalDate to);

    @ApiLogs({
        @ApiLog(date = "2026.11.12", author = Author.SUHSAECHAN, issueNumber = 1032, description = "결제 목록 건별 회수 API 추가"),
    })
    @Operation(summary = "결제 건별 회수", description = "회원 상세 구매 회수와 같은 처리 (REVOKED + 등급 재계산 + 감사 기록). 다른 회원 구매 403, 없는 구매 404, 이미 회수 400 INVALID_REQUEST")
    ResponseEntity<RevocationResult> revokePurchase(UUID entitlementPurchaseUuid, AdminPurchaseRevokeRequest request);

    @ApiLogs({
        @ApiLog(date = "2026.11.12", author = Author.SUHSAECHAN, issueNumber = 1032, description = "App Store 환불 점검 상태·기록 API 추가"),
    })
    @Operation(summary = "App Store 환불 점검 상태", description = "인앱 결제 키 설정 여부, 샌드박스 재조회·소비 정보 자동 응답 설정, 최근 14회 실행")
    ResponseEntity<AppStoreRefundCheckOverview> getAppStoreRefundCheckOverview();

    @ApiLogs({
        @ApiLog(date = "2026.11.12", author = Author.SUHSAECHAN, issueNumber = 1032, description = "App Store 환불 점검 즉시 실행 API 추가"),
    })
    @Operation(summary = "App Store 환불 점검 지금 실행", description = "최근 180일 App Store 검증 구매를 거래 조회해 Apple 회수 표시면 회수. 키가 없으면 건너뛰고 APP_STORE_KEY_NOT_CONFIGURED 기록")
    ResponseEntity<RefundCheckRunResponse> runAppStoreRefundCheck();

    @ApiLogs({
        @ApiLog(date = "2026.11.12", author = Author.SUHSAECHAN, issueNumber = 1032, description = "App Store 알림 수신 기록 API 추가"),
    })
    @Operation(summary = "App Store 알림 수신 기록", description = "최신 수신순: 유형·하위 유형·알림 ID·거래 ID(가림)·환경·처리 결과. 환불 요청(CONSUMPTION_REQUEST)은 isRefundRequest true")
    ResponseEntity<AppStoreNotificationLogPageResponse> getAppStoreNotifications(int page, int size);
}
