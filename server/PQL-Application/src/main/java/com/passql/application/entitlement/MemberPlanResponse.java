package com.passql.application.entitlement;

import java.time.LocalDateTime;

/**
 * 내 등급 응답: 결제 스위치, 등급(FREE/PRO), 프로 만료일, 오늘 무료 사용량
 *
 * @param isBillingEnabled       결제 스위치 (false 면 앱은 잠금 UI 를 그리지 않음)
 * @param plan                   "FREE" 또는 "PRO" (스위치 꺼짐이면 항상 "PRO")
 * @param proExpiresAt           프로 만료 시각 KST (유효한 프로가 아니면 null)
 * @param todayRandomSolvedCount 오늘 푼 무료 랜덤 문제 수
 * @param dailyFreeLimit         무료 하루 랜덤 문제 한도
 * @param purchasableUntil       구매 가능 마감 시각 KST (구매 불가 시 null)
 */
public record MemberPlanResponse(
    boolean isBillingEnabled,
    String plan,
    LocalDateTime proExpiresAt,
    int todayRandomSolvedCount,
    int dailyFreeLimit,
    LocalDateTime purchasableUntil
) {
}
