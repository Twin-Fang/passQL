package com.passql.ai.dto;

/**
 * 모델 1개 단가 (USD / 1M 토큰, output 은 thinking 포함, app_setting ai.model_price_table 1항목)
 */
public record AiModelPrice(
        String modelName,
        double inputUsdPerMillion,
        double outputUsdPerMillion
) {
}
