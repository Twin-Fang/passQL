package com.passql.meta.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;

import java.util.List;
import java.util.UUID;

/** 건의 일괄 상태 변경 요청 (최대 100건, status: FeedbackStatus 이름) */
public record FeedbackBulkStatusRequest(
    @NotEmpty @Size(max = 100) List<UUID> feedbackUuids,
    @NotBlank String status
) {
}
