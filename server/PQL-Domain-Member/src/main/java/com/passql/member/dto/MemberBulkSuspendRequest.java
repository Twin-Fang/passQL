package com.passql.member.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/** 회원 일괄 제재 요청: 대상 회원들에게 같은 분류·사유·만료 시각 적용 (최대 100명) */
@Getter
@Setter
public class MemberBulkSuspendRequest {

    @NotEmpty
    @Size(max = 100)
    private List<UUID> memberUuids;

    // SuspendReasonCategory 이름 (비면 분류 없음)
    private String reasonCategory;

    private String reason;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
    private LocalDateTime suspendUntil;
}
