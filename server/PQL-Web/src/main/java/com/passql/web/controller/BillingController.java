package com.passql.web.controller;

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

    // Play 구매 확인 > 등급 부여·소모 > 내 등급
    @PostMapping("/play/verify")
    public MemberPlanResponse verifyPlayPurchase(
        @AuthMember LoginMember loginMember,
        @Valid @RequestBody PlayVerifyRequest request
    ) {
        return playBillingService.verify(loginMember.memberUuid(), request);
    }
}
