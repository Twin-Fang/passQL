package com.passql.meta.dto;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 사업자 정보 표기 (#658): 상호, 대표자, 사업자등록번호, 문의 이메일, 통신판매업 신고번호
 * 원본은 app_setting business.* > 빈 값은 null (앱·웹은 null 줄 숨김, companyName 이 null 이면 섹션 숨김)
 */
public record BusinessInfoResponse(
        @Schema(nullable = true) String companyName,
        @Schema(nullable = true) String representativeName,
        @Schema(nullable = true) String registrationNumber,
        @Schema(nullable = true) String contactEmail,
        @Schema(nullable = true) String mailOrderSalesNumber
) {
}
