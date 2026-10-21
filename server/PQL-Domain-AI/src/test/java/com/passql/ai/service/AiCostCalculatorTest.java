package com.passql.ai.service;

import com.passql.ai.dto.AiModelPrice;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.within;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/** 비용 추정 (#557): 정확 일치 > 가장 긴 접두 일치 > 미등록, JSON 깨짐은 빈 표 */
class AiCostCalculatorTest {

    private static final String PRICE_TABLE_JSON = """
            {"gemini-2.5-flash-lite":{"inputUsdPerMillion":0.10,"outputUsdPerMillion":0.40},
             "gemini-2.5-flash":{"inputUsdPerMillion":0.30,"outputUsdPerMillion":2.50}}
            """;

    private AppSettingService appSettingService;
    private AiCostCalculator aiCostCalculator;

    @BeforeEach
    void setUp() {
        appSettingService = mock(AppSettingService.class);
        aiCostCalculator = new AiCostCalculator(appSettingService);
        when(appSettingService.getString(AppSettingKeys.AI_MODEL_PRICE_TABLE)).thenReturn(PRICE_TABLE_JSON);
    }

    @Test
    void 정확히_일치하는_모델_단가로_계산() {
        assertThat(aiCostCalculator.findPrice("gemini-2.5-flash"))
                .contains(new AiModelPrice("gemini-2.5-flash", 0.30, 2.50));
        // 입력 1M × 0.30 + 출력 0.5M × 2.50
        assertThat(aiCostCalculator.estimateCostUsd("gemini-2.5-flash", 1_000_000, 500_000)).isCloseTo(1.55, within(1e-9));
    }

    @Test
    void 접두_일치는_가장_긴_모델명을_고른다() {
        assertThat(aiCostCalculator.findPrice("gemini-2.5-flash-lite-preview-09-2026"))
                .map(AiModelPrice::modelName)
                .contains("gemini-2.5-flash-lite");
        assertThat(aiCostCalculator.isPriceRegistered("gemini-2.5-flash-lite-preview-09-2026")).isTrue();
    }

    @Test
    void 미등록_모델은_비용_0() {
        assertThat(aiCostCalculator.isPriceRegistered("gpt-4o")).isFalse();
        assertThat(aiCostCalculator.isPriceRegistered(null)).isFalse();
        assertThat(aiCostCalculator.estimateCostUsd("gpt-4o", 1_000_000, 1_000_000)).isZero();
    }

    @Test
    void 단가표_JSON이_깨지면_빈_표() {
        when(appSettingService.getString(AppSettingKeys.AI_MODEL_PRICE_TABLE)).thenReturn("{broken");

        assertThat(aiCostCalculator.getPriceTable()).isEmpty();
        assertThat(aiCostCalculator.estimateCostUsd("gemini-2.5-flash", 1_000_000, 0)).isZero();
    }

    @Test
    void 단가표는_모델명순() {
        assertThat(aiCostCalculator.getPriceTable())
                .extracting(AiModelPrice::modelName)
                .containsExactly("gemini-2.5-flash", "gemini-2.5-flash-lite");
    }

    @Test
    void 월_예산_설정이_없거나_잘못되면_기본값() {
        when(appSettingService.getString(AppSettingKeys.AI_MONTHLY_BUDGET_USD)).thenReturn("25.5");
        assertThat(aiCostCalculator.getMonthlyBudgetUsd()).isEqualTo(25.5);

        when(appSettingService.getString(AppSettingKeys.AI_MONTHLY_BUDGET_USD)).thenReturn("abc");
        assertThat(aiCostCalculator.getMonthlyBudgetUsd()).isEqualTo(AiCostCalculator.DEFAULT_MONTHLY_BUDGET_USD);

        when(appSettingService.getString(AppSettingKeys.AI_MONTHLY_BUDGET_USD))
                .thenThrow(new CustomException(ErrorCode.SETTING_NOT_FOUND));
        assertThat(aiCostCalculator.getMonthlyBudgetUsd()).isEqualTo(AiCostCalculator.DEFAULT_MONTHLY_BUDGET_USD);
    }
}
