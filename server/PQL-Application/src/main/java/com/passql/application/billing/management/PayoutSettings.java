package com.passql.application.billing.management;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

/**
 * 실수령액 추정 설정 (app_setting billing.*, 관리자 화면 표시·저장 요청 공통): 스토어 수수료율, 원화 부가세율 (%, 0 ~ 100)
 */
public record PayoutSettings(
    @NotNull @DecimalMin("0") @DecimalMax("100") Double playFeeRatePercent,
    @NotNull @DecimalMin("0") @DecimalMax("100") Double appStoreFeeRatePercent,
    @NotNull @DecimalMin("0") @DecimalMax("100") Double krwVatRatePercent) {
}
