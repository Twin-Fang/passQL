package com.passql.web.support;

import com.passql.application.billing.management.AdminPurchaseRowResponse;
import org.springframework.http.ResponseEntity;

import java.util.Arrays;
import java.util.List;

/**
 * 관리자 결제 목록 > CSV (화면 표와 같은 열, #1032): 파일 응답은 AdminCsvResponseWriter 공통
 */
public final class AdminBillingCsvExporter {

    private AdminBillingCsvExporter() {
    }

    /** 결제 목록: 구매 시각, 스토어, 상품, 상태, 금액, 통화, 만료, 회수 시각, 주문 번호(가림), 회원, 테스트 계정, 환불 요청 */
    public static ResponseEntity<byte[]> purchases(List<AdminPurchaseRowResponse> purchaseRows) {
        List<List<?>> rows = purchaseRows.stream()
                .<List<?>>map(row -> Arrays.asList(row.purchasedAt(), row.store(), row.productId(), row.status(),
                        row.amount() == null ? "" : row.amount(), nullToEmpty(row.currencyCode()),
                        row.grantedExpiresAt() == null ? "" : row.grantedExpiresAt(),
                        row.revokedAt() == null ? "" : row.revokedAt(), row.maskedOrderId(), row.memberUuid(),
                        nullToEmpty(row.memberNickname()), Boolean.TRUE.equals(row.isTestAccount()) ? "Y" : "",
                        nullToEmpty(row.refundRequestState())))
                .toList();
        return AdminCsvResponseWriter.toResponse("purchases.csv",
                List.of("구매 시각", "스토어", "상품", "상태", "금액", "통화", "만료", "회수 시각", "주문 번호", "회원 UUID",
                        "닉네임", "테스트 계정", "환불 요청"),
                rows);
    }

    private static String nullToEmpty(String value) {
        return value == null ? "" : value;
    }
}
