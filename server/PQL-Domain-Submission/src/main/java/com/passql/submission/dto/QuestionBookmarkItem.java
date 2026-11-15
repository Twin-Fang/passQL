package com.passql.submission.dto;

import com.passql.submission.constant.MockExamSubject;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.UUID;

/** 즐겨찾기 목록 항목 (#1082): 지문 50자 미리보기, 토픽, 과목, 추가 시각 */
public record QuestionBookmarkItem(
    UUID questionUuid,
    String stemPreview,
    @Schema(nullable = true) String topicName,
    MockExamSubject subject,
    LocalDateTime bookmarkedAt
) {}
