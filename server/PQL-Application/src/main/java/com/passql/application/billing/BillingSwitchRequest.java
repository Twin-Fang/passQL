package com.passql.application.billing;

import jakarta.validation.constraints.NotNull;

/** 관리자 결제 스위치 전환 요청 */
public record BillingSwitchRequest(@NotNull Boolean isEnabled) {
}
