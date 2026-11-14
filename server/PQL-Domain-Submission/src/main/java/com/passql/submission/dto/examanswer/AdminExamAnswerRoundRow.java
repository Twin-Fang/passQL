package com.passql.submission.dto.examanswer;

import java.time.LocalDate;
import java.util.UUID;

/**
 * 관리자 가답안 회차 목록 행
 */
public record AdminExamAnswerRoundRow(UUID roundUuid, String certType, int roundNumber, LocalDate examDate, String title,
                                      String status, String notice, long participantCount) {
}
