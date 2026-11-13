package com.passql.application.billing.management;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.UUID;

/** 결제 목록 건별 회수 요청 (#1032): 구매 소유 회원(서버가 대조), 회수 사유 (회원 상세 회수와 같은 검증) */
public record AdminPurchaseRevokeRequest(@NotNull UUID memberUuid, @NotBlank String reason) {
}
