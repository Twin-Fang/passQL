package com.passql.member.dto;

import com.passql.member.entity.PushSendHistory;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 관리자 발송 요청
 * audience: ALL, MEMBER(targetMemberUuid 필수) / linkTarget: PushLinkTarget 이름 (QUESTION_DETAIL 은 linkQuestionUuid 필수)
 * deliveryMode: PUSH_AND_INBOX, INBOX_ONLY (비면 PUSH_AND_INBOX)
 */
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class PushSendRequest {

    @NotBlank
    @Size(max = PushSendHistory.MAX_TITLE_LENGTH)
    private String title;

    @NotBlank
    @Size(max = PushSendHistory.MAX_BODY_LENGTH)
    private String body;

    @NotBlank
    private String audience;

    private String targetMemberUuid;

    @NotBlank
    private String linkTarget;

    private String linkQuestionUuid;

    private String deliveryMode;
}
