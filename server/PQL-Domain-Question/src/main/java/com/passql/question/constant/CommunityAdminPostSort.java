package com.passql.question.constant;

import org.springframework.data.domain.Sort;

/** 관리자 글·신고 목록 정렬 4종 (신고 많은 순은 신고 수 동률이면 최신순) */
public enum CommunityAdminPostSort {
    NEWEST(Sort.by(Sort.Order.desc("createdAt"))),
    OLDEST(Sort.by(Sort.Order.asc("createdAt"))),
    MOST_REPORTED(Sort.by(Sort.Order.desc("reportCount"), Sort.Order.desc("createdAt"))),
    MOST_LIKED(Sort.by(Sort.Order.desc("likeCount"), Sort.Order.desc("createdAt")));

    private final Sort sort;

    CommunityAdminPostSort(Sort sort) {
        this.sort = sort;
    }

    public Sort toSort() {
        return sort;
    }
}
