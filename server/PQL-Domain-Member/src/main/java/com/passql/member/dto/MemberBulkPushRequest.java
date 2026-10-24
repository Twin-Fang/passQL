package com.passql.member.dto;

import com.passql.member.entity.PushSendHistory;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;

import java.util.List;
import java.util.UUID;

/** 회원 푸시 요청: 대상 회원들에게 같은 제목·본문 발송 (최대 100명, 푸시 + 알림함) */
public record MemberBulkPushRequest(
    @NotEmpty @Size(max = 100) List<UUID> memberUuids,
    @NotBlank @Size(max = PushSendHistory.MAX_TITLE_LENGTH) String title,
    @NotBlank @Size(max = PushSendHistory.MAX_BODY_LENGTH) String body
) {
}
