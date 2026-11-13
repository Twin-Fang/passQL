package com.passql.application.billing;

/**
 * 결제 미리보기 목록 1항목
 * entry: 설정에 저장된 원문 항목 (삭제 요청 키), nickname: 회원 없음·UUID 형식 오류면 null
 */
public record BillingPreviewMember(String entry, String nickname) {
}
