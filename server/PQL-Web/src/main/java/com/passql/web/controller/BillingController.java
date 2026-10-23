package com.passql.web.controller;

import com.passql.application.billing.AppStoreBillingService;
import com.passql.application.billing.AppStoreNotificationRequest;
import com.passql.application.billing.AppStoreVerifyRequest;
import com.passql.application.billing.PlayBillingService;
import com.passql.application.billing.PlayVerifyRequest;
import com.passql.application.entitlement.MemberPlanResponse;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/billing")
@RequiredArgsConstructor
public class BillingController implements BillingControllerDocs {

    private final PlayBillingService playBillingService;
    private final AppStoreBillingService appStoreBillingService;

    // Play 구매 확인 > 등급 부여·소모 > 내 등급
    @PostMapping("/play/verify")
    public MemberPlanResponse verifyPlayPurchase(
        @AuthMember LoginMember loginMember,
        @Valid @RequestBody PlayVerifyRequest request
    ) {
        return playBillingService.verify(loginMember.memberUuid(), request);
    }

    // App Store 구매 확인 > 등급 부여 > 내 등급
    @PostMapping("/app-store/verify")
    public MemberPlanResponse verifyAppStorePurchase(
        @AuthMember LoginMember loginMember,
        @Valid @RequestBody AppStoreVerifyRequest request
    ) {
        return appStoreBillingService.verify(loginMember.memberUuid(), request);
    }

    // App Store 서버 알림 V2 수신 (인증 없음, Apple 서명으로 검증) > 환불·회수 반영
    @PostMapping("/app-store/notifications")
    public void receiveAppStoreNotification(@Valid @RequestBody AppStoreNotificationRequest request) {
        appStoreBillingService.handleNotification(request);
    }
}
