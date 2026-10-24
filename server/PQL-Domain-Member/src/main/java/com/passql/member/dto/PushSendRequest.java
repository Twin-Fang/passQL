package com.passql.member.dto;

import com.passql.member.entity.PushSendHistory;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 관리자 발송 요청
 * audience: PushAudience 이름 (MEMBER 는 targetMemberUuid 필수, INACTIVE_MEMBERS 는 inactiveDays 필수) / linkTarget: PushLinkTarget 이름 (QUESTION_DETAIL 은 linkQuestionUuid 필수)
 * deliveryMode: PUSH_AND_INBOX, INBOX_ONLY (비면 PUSH_AND_INBOX) / scheduledAt: KST 예약 시각 (비면 즉시)
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

    private Integer inactiveDays;

    private LocalDateTime scheduledAt;

    /** 세그먼트·예약 없는 즉시 발송 요청 */
    public PushSendRequest(String title, String body, String audience, String targetMemberUuid,
                           String linkTarget, String linkQuestionUuid, String deliveryMode) {
        this(title, body, audience, targetMemberUuid, linkTarget, linkQuestionUuid, deliveryMode, null, null);
    }
}
