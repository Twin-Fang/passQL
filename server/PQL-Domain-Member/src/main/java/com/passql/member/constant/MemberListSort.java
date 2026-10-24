package com.passql.member.constant;

import org.springframework.data.domain.Sort;

/** 관리자 회원 목록 정렬 5종 */
public enum MemberListSort {
    NEWEST_JOINED("가입 최신순", Sort.by(Sort.Direction.DESC, "createdAt")),
    OLDEST_JOINED("가입 오래된순", Sort.by(Sort.Direction.ASC, "createdAt")),
    // 접속순 2종: Specification 조회가 null 우선순위 정렬을 지원하지 않아 정렬은 MemberSpecification.orderByLastSeen 이 담당
    RECENT_SEEN("최근 접속순", Sort.unsorted()),
    OLDEST_SEEN("오래 미접속순", Sort.unsorted()),
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
