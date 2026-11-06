package com.passql.application.ads;

/**
 * 서명을 확인한 AdMob 보상형 광고 서버 검증 콜백 값 (URL 디코딩 끝난 값, 없으면 null)
 * userId = 앱이 넣은 회원 UUID, customData = 앱이 광고마다 만든 보상 표식
 */
public record AdMobRewardCallback(
    String adUnit,
    String userId,
    String customData,
    String transactionId
) {
}
