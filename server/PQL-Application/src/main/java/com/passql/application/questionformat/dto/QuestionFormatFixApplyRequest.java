package com.passql.application.questionformat.dto;

import jakarta.validation.constraints.NotEmpty;

import java.util.List;
import java.util.UUID;

/**
 * 자동 정리 적용 요청 (#905): 미리보기에서 고른 문제 (정리 내용은 서버가 다시 계산)
 */
public record QuestionFormatFixApplyRequest(@NotEmpty List<UUID> questionUuids) {
}
