package com.passql.application.billing;

import jakarta.validation.constraints.NotBlank;

/**
 * Play 구매 확인 요청 (앱 구매 완료 후 전송)
 *
 * @param productId     Play 상품 ID (PassProduct 의 pro_pass_3m, pro_pass_1m)
 * @param purchaseToken Play 구매 토큰 (민감값, 로그 금지)
 */
public record PlayVerifyRequest(
    @NotBlank String productId,
    @NotBlank String purchaseToken
) {
}
