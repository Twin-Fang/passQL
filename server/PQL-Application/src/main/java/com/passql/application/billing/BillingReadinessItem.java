package com.passql.application.billing;

/**
 * 결제 켜기 전 점검표 1항목 (읽기 전용 상태)
 * statusText: 화면 배지 문구 (비밀 값은 설정 여부만, 값 자체는 담지 않음)
 */
public record BillingReadinessItem(String label, Boolean isReady, String statusText) {
}
