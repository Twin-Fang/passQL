package com.passql.submission.dto.mockexam;

import com.passql.submission.constant.MockExamRoundType;

import java.time.LocalDate;
import java.util.UUID;

/**
 * 회차 공개 결과: 이번 요청으로 새로 공개됐는지 + 종류·시험일 (FINAL 공개 알림 판단, #1084)
 */
public record AdminMockExamPublishResult(UUID roundUuid, boolean isNewlyPublished, MockExamRoundType roundType,
                                         LocalDate examDate) {
}
