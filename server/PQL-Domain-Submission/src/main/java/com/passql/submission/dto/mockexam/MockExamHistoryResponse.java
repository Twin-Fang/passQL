package com.passql.submission.dto.mockexam;

import com.passql.submission.constant.MockExamFailReason;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * 점수 추이 (프로): 채점된 응시 제출 시간순
 */
public record MockExamHistoryResponse(int passScore, List<HistoryEntry> attempts) {

    public record HistoryEntry(UUID attemptUuid, int roundNumber, String title, LocalDateTime submittedAt,
                               int totalScore, int subjectOneScore, int subjectTwoScore, boolean isPassed,
                               MockExamFailReason failReason) {
    }
}
