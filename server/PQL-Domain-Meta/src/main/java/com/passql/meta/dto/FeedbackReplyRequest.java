package com.passql.meta.dto;

import com.passql.meta.entity.Feedback;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** 건의 답변 요청: 작성자 알림함으로 전달 (푸시 포함) */
public record FeedbackReplyRequest(@NotBlank @Size(max = Feedback.MAX_REPLY_LENGTH) String message) {
}
