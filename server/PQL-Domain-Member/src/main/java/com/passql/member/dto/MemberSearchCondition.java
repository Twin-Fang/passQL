package com.passql.member.dto;

import com.passql.member.constant.MemberListSort;
import com.passql.member.constant.MemberPlanFilter;
import com.passql.member.constant.MemberRole;
import com.passql.member.constant.MemberStatus;
import lombok.Getter;
import lombok.Setter;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;

@Getter
@Setter
public class MemberSearchCondition {
    private String nickname;
    // 회원 UUID 정확히 일치 (형식이 틀리면 결과 없음)
    private String memberUuid;
    private MemberStatus status;
    private MemberRole role;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate joinedFrom;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate joinedTo;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate lastSeenFrom;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate lastSeenTo;

    private Boolean includeTest = false;

    private MemberPlanFilter planFilter;

    // 비면 가입 최신순
    private MemberListSort sort;

    public MemberListSort getSortOrDefault() {
        return sort == null ? MemberListSort.NEWEST_JOINED : sort;
    }
}
