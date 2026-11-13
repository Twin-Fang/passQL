package com.passql.application.entitlement;

import com.passql.member.constant.MemberPlan;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 내 등급 응답: 결제 스위치, 등급(FREE/PRO), 프로 만료일, 오늘 무료 사용량·한도·보너스, 최근 구매, 판매 이용권
 *
 * @param isBillingEnabled       회원 기준 결제 켜짐 (전체 스위치 또는 미리보기 목록 회원, false 면 앱은 잠금 UI 를 그리지 않음)
 * @param plan                   FREE 또는 PRO (스위치 꺼짐이면 항상 PRO, 와이어 값은 enum 이름 문자열)
 * @param proExpiresAt           프로 만료 시각 KST (유효한 프로가 아니면 null)
 * @param todayRandomSolvedCount 오늘 푼 무료 랜덤 문제 수
 * @param dailyFreeLimit         무료 하루 랜덤 문제 기본 한도 (보너스 제외, 혜택 비교 문구용)
 * @param purchasableUntil       deprecated: passOptions 의 3개월권 expiresAtIfPurchased 와 같은 값 (출시 앱 1.36·1.37 호환용, 결제 꺼짐이면 null)
 * @param lastPurchasedAt        가장 최근 검증 구매 시각 KST (구매 없음·관리자 부여만 있으면 null)
 * @param lastOrderId            가장 최근 검증 구매의 Play 주문 번호 (구매 없음·관리자 부여만 있으면 null)
 * @param passOptions            판매 이용권 목록 (3개월 먼저, 결제 꺼짐이면 빈 목록)
 * @param todayFreeLimit         오늘 무료 랜덤 문제 유효 한도 (기본 + 받은 보너스, 결제 꺼짐·프로면 기본)
 * @param dailyBonus             오늘 받은 무료 한도 보너스 (결제 꺼짐·프로면 없음)
 */
public record MemberPlanResponse(
    boolean isBillingEnabled,
    MemberPlan plan,
    @Schema(nullable = true) LocalDateTime proExpiresAt,
    int todayRandomSolvedCount,
    int dailyFreeLimit,
    @Schema(nullable = true, deprecated = true) LocalDateTime purchasableUntil,
    @Schema(nullable = true) LocalDateTime lastPurchasedAt,
    @Schema(nullable = true) String lastOrderId,
    List<PassOption> passOptions,
    int todayFreeLimit,
    DailyFreeBonus dailyBonus
) {
}
