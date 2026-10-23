package com.passql.application.entitlement;

import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * 이용권 만료일 계산: max(구매 시각, 현재 프로 만료일) + 이용 일수
 * 신규·만료 후 구매 > 구매 시각부터, 보유 중 재구매 > 현재 만료일 뒤로 이어 붙임 (구매·등급 응답·환불 재생 공통)
 */
@Component
public class PassExpiryCalculator {

    /** 만료일 계산 (currentExpiresAt 은 프로가 아니면 null) */
    public LocalDateTime calculateExpiresAt(LocalDateTime purchasedAt, LocalDateTime currentExpiresAt, int durationDays) {
        boolean isPassStillActive = currentExpiresAt != null && currentExpiresAt.isAfter(purchasedAt);
        LocalDateTime extensionBase = isPassStillActive ? currentExpiresAt : purchasedAt;
        return extensionBase.plusDays(durationDays);
    }
}
