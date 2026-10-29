package com.passql.common.util;

/**
 * 사용자 목록 API 페이지 크기 공통: 기본값, 상한, 요청값 보정
 * 관리자 화면 페이지 크기는 AdminPageRequest 별도
 */
public final class ClientPageSize {

    // 페이지 크기 기본값·상한 (건)
    public static final int DEFAULT_PAGE_SIZE = 20;
    public static final int MAX_PAGE_SIZE = 50;

    private ClientPageSize() {
    }

    /** 요청 크기 > 적용 크기 (null·1 미만 > 기본값, 상한 초과 > 상한) */
    public static int clamp(Integer requestedSize) {
        if (requestedSize == null || requestedSize < 1) {
            return DEFAULT_PAGE_SIZE;
        }
        return Math.min(requestedSize, MAX_PAGE_SIZE);
    }
}
