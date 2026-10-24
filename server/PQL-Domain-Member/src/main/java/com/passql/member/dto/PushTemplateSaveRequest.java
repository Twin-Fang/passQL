package com.passql.member.dto;

import com.passql.member.entity.PushSendHistory;
import com.passql.member.entity.PushTemplate;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** 푸시 템플릿 저장 요청 (같은 이름이면 덮어쓰기, linkTarget 은 PushLinkTarget 이름) */
public record PushTemplateSaveRequest(
        @NotBlank @Size(max = PushTemplate.MAX_NAME_LENGTH) String name,
        @NotBlank @Size(max = PushSendHistory.MAX_TITLE_LENGTH) String title,
        @NotBlank @Size(max = PushSendHistory.MAX_BODY_LENGTH) String body,
        @NotBlank String linkTarget,
        String linkQuestionUuid
) {
}
