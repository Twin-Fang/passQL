package com.passql.web.controller;

import com.passql.application.entitlement.AdBonusGrantService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/ads")
@RequiredArgsConstructor
public class AdRewardCallbackController implements AdRewardCallbackControllerDocs {

    private final AdBonusGrantService adBonusGrantService;

    // AdMob 보상형 광고 서버 검증 콜백 (인증 없음, Google 서명으로 검증, #860). 서명 대상이 원본 쿼리라 디코딩 전 문자열을 넘김
    @GetMapping("/admob/reward-callback")
    public void receiveRewardCallback(HttpServletRequest request) {
        adBonusGrantService.grantByServerVerification(request.getQueryString());
    }
}
