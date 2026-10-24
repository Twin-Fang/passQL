package com.passql.member.constant;

import org.springframework.data.domain.Sort;

/** 관리자 회원 목록 정렬 5종 */
public enum MemberListSort {
    NEWEST_JOINED("가입 최신순", Sort.by(Sort.Direction.DESC, "createdAt")),
    OLDEST_JOINED("가입 오래된순", Sort.by(Sort.Direction.ASC, "createdAt")),
    RECENT_SEEN("최근 접속순", Sort.by(Sort.Order.desc("lastSeenAt").nullsLast(), Sort.Order.desc("createdAt"))),
    OLDEST_SEEN("오래 미접속순", Sort.by(Sort.Order.asc("lastSeenAt").nullsFirst(), Sort.Order.desc("createdAt"))),
    NICKNAME("닉네임순", Sort.by(Sort.Direction.ASC, "nickname"));

    // 관리자 화면 표시 이름
    private final String label;
    private final Sort sort;

    MemberListSort(String label, Sort sort) {
        this.label = label;
        this.sort = sort;
    }

    public String getLabel() {
        return label;
    }

    public Sort toSort() {
        return sort;
    }
}
