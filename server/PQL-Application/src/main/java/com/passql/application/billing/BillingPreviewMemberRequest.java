package com.passql.application.billing;

import jakarta.validation.constraints.NotBlank;

/** 관리자 결제 미리보기 회원 추가·삭제 요청 (추가: 회원 UUID, 삭제: 목록에 저장된 항목 원문) */
public record BillingPreviewMemberRequest(@NotBlank String memberUuid) {
}
