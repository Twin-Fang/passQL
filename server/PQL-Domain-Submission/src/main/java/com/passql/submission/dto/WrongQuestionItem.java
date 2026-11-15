package com.passql.submission.dto;

import com.passql.submission.constant.MockExamSubject;
import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 마이페이지 오답 노트 항목.
 * stem은 마크다운 제거 후 앞 50자만 내려줌 — 목록 표시용 미리보기.
 */
public record WrongQuestionItem(
    UUID questionUuid,
    String stemPreview,
    @Schema(nullable = true) String topicName,
    LocalDateTime lastWrongAt,
    @Schema(description = "틀린 횟수 (#1081)")
    int wrongCount,
    @Schema(description = "정리됨: 그 문제 최신 제출이 정답 (#1081)")
    Boolean isResolved,
    @Schema(description = "과목: 토픽 data_modeling 이면 SUBJECT_ONE, 그 외 SUBJECT_TWO (#1081)")
    MockExamSubject subject
) {}
