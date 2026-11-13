package com.passql.application.billing;

import java.util.List;

/**
 * App Store 환불 점검 화면 값 (#1032): 키 설정 여부, 샌드박스 재조회·소비 정보 자동 응답 설정, 최근 실행 기록
 */
public record AppStoreRefundCheckOverview(
    Boolean isServerApiConfigured,
    Boolean isSandboxFallbackEnabled,
    Boolean isConsumptionResponseEnabled,
    List<RefundCheckRunResponse> recentRuns) {
}
