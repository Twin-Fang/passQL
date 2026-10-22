package com.passql.application.billing;

import java.time.Instant;

/**
 * Play 구매 조회 결과 (Play 라이브러리 타입과 분리)
 *
 * @param orderId          Play 주문 번호 (없을 수 있음)
 * @param purchaseState    구매 상태: 0 구매 완료, 1 취소, 2 대기
 * @param consumptionState 소모 상태: 0 미소모, 1 소모 완료
 * @param purchasedAt      구매 시각 (없으면 null)
 * @param obfuscatedExternalAccountId 앱이 결제 때 넣은 계정 값 = SHA-256(회원 uuid) hex (예전 구매·테스트는 null)
 */
public record PlayPurchaseSnapshot(String orderId, int purchaseState, int consumptionState, Instant purchasedAt,
                                   String obfuscatedExternalAccountId) {
}
