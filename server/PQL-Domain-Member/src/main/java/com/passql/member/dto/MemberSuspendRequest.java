package com.passql.member.dto;

import lombok.Getter;
import lombok.Setter;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDateTime;

@Getter
@Setter
public class MemberSuspendRequest {
    // SuspendReasonCategory 이름 (비면 분류 없음)
    private String reasonCategory;

    private String reason;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
    private LocalDateTime suspendUntil;
}
