package com.passql.application.entitlement;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 광고 보너스 받기 요청 (#860, 본문 없는 출시 앱 요청도 허용)
 *
 * @param rewardNonce 앱이 광고마다 만든 보상 표식 (AdMob 서버 검증 custom_data 와 같은 값, 없으면 null)
 */
public record AdBonusRequest(
    @Schema(nullable = true, description = "광고마다 만든 보상 표식 (AdMob 서버 검증 custom_data 와 같은 값)") String rewardNonce
) {
}
