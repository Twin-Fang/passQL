package com.passql.submission.dto.examanswer;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 관리자 가답안 답안지 목록 행 (#1126): 제출 시각(재제출이면 마지막), 경로, 토큰 해시 앞 6자리, 답 50자
 */
public record AdminExamAnswerSheetRow(UUID sheetUuid, LocalDateTime submittedAt, String source, String clientTokenHashPrefix,
                                      String answers) {
}
