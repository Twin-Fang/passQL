package com.passql.web.support;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

/**
 * 관리자 목록 페이지 요청 보정: page 음수 > 0, size 1~100 범위로
 */
public final class AdminPageRequest {

    // 관리자 목록 기본 페이지 크기 (@RequestParam defaultValue 용 문자열 상수)
    public static final String DEFAULT_PAGE_SIZE = "20";
    // 관리자 목록 최대 페이지 크기 (건)
    public static final int MAX_PAGE_SIZE = 100;
    // 관리자 목록 정렬 기준 필드 (BaseEntity.createdAt)
    private static final String CREATED_AT_FIELD = "createdAt";

    private AdminPageRequest() {
    }

    /** 보정된 page·size + 지정 정렬 */
    public static Pageable of(int page, int size, Sort sort) {
        int correctedPage = Math.max(0, page);
        int correctedSize = Math.min(Math.max(1, size), MAX_PAGE_SIZE);
        return PageRequest.of(correctedPage, correctedSize, sort);
    }

    /** 보정된 page·size + 최신 등록순 */
    public static Pageable newestFirst(int page, int size) {
        return of(page, size, sortByNewestFirst());
    }

    /** 보정된 page·size + 지정 시각 필드 최신순 (BaseEntity 미상속 기록 테이블용, 예: occurredAt) */
    public static Pageable newestFirstBy(int page, int size, String timeField) {
        return of(page, size, Sort.by(Sort.Direction.DESC, timeField));
    }

    /** 최신 등록순 정렬 (createdAt DESC) */
    public static Sort sortByNewestFirst() {
        return Sort.by(Sort.Direction.DESC, CREATED_AT_FIELD);
    }
}
