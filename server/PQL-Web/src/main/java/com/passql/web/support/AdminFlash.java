package com.passql.web.support;

/**
 * 관리자 리다이렉트 후 토스트 플래시 속성 이름 (layout.html adminFlashToast 가 읽음)
 */
public final class AdminFlash {

    // 저장 성공 토스트 문구
    public static final String TOAST_MESSAGE = "toastMessage";

    // 회원 상세 프로 부여 실패 문구 (회원 상세 등급 카드에 표시)
    public static final String ENTITLEMENT_ERROR_MESSAGE = "entitlementErrorMessage";

    private AdminFlash() {
    }
}
