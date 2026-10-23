package com.passql.application.billing;

import jakarta.validation.constraints.NotBlank;

/**
 * App Store 구매 확인 요청 (앱 StoreKit 2 구매 완료 후 전송)
 *
 * @param productId         App Store 상품 ID (PassProduct 의 pro_pass_3m, pro_pass_1m)
 * @param signedTransaction StoreKit 2 거래 JWS (Transaction.jwsRepresentation, 민감값·로그 금지)
 */
public record AppStoreVerifyRequest(
    @NotBlank String productId,
    @NotBlank String signedTransaction
) {
}
