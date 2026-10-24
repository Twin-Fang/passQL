package com.passql.meta.constant;

import com.passql.meta.dto.AdminAccountView;

import java.time.LocalDateTime;
import java.util.Comparator;

/** 관리자 계정 목록 정렬 3종: 생성순, 아이디순, 최근 로그인순 */
public enum AdminAccountSort {
    CREATED(Comparator.comparing(AdminAccountView::createdAt, Comparator.nullsLast(Comparator.<LocalDateTime>naturalOrder()))),
    USERNAME(Comparator.comparing(AdminAccountView::username, String.CASE_INSENSITIVE_ORDER)),
    // 로그인 기록 없는 계정은 맨 뒤
    LAST_LOGIN(Comparator.comparing(AdminAccountView::lastLoginAt, Comparator.nullsLast(Comparator.<LocalDateTime>reverseOrder())));

    private final Comparator<AdminAccountView> comparator;

    AdminAccountSort(Comparator<AdminAccountView> comparator) {
        this.comparator = comparator;
    }

    public Comparator<AdminAccountView> getComparator() {
        return comparator;
    }

    /** 요청값 > 정렬 (없거나 모르는 값은 생성순) */
    public static AdminAccountSort fromRequestValueOrDefault(String requestValue) {
        for (AdminAccountSort sort : values()) {
            if (sort.name().equalsIgnoreCase(requestValue)) {
                return sort;
            }
        }
        return CREATED;
    }
}
