package com.passql.submission.dto.mockexam;

import com.passql.submission.constant.MockExamAttemptStatus;
import com.passql.submission.constant.MockExamFailReason;
import com.passql.submission.constant.MockExamRoundType;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * 회차 목록: 시험 형식, 풀이 중 응시(이어 풀기), 공개 회차별 종류·시작 가능 여부·최고 점수·마지막 응시
 */
public record MockExamRoundListResponse(
    MockExamRuleResponse examRule,
    @Schema(nullable = true) InProgressAttempt inProgressAttempt,
    List<RoundSummary> rounds
) {

    public record InProgressAttempt(UUID attemptUuid, UUID roundUuid, int roundNumber, String title,
                                    long remainingSeconds, int answeredCount) {
    }

    public record RoundSummary(
        UUID roundUuid,
        int roundNumber,
        String title,
        @Schema(description = "회차 종류 (MOCK 모의고사, PAST_EXAM 기출 복원, #1079)") MockExamRoundType roundType,
        @Schema(nullable = true, description = "실제 시험 회차 번호 (PAST_EXAM 만, 예 62)") Integer examRoundNumber,
        @Schema(nullable = true, description = "실제 시험일 (PAST_EXAM 만)") LocalDate examDate,
        @Schema(description = "무료 체험 회차 (모의고사 회차 중 번호가 가장 작은 회차)") boolean isFreeTrialRound,
        @Schema(description = "무료 기출 회차 (가장 최근 기출 회차, 무료 회원도 체험 횟수와 별개로 응시)") boolean isFreePastExamRound,
        boolean canStart,
        @Schema(nullable = true) MockExamStartBlockReason startBlockReason,
        int submittedAttemptCount,
        @Schema(nullable = true) Integer bestScore,
        @Schema(nullable = true, description = "최고 점수 응시(동점이면 최근)의 합격 여부 (과락 포함)") Boolean bestAttemptIsPassed,
        @Schema(nullable = true, description = "최고 점수 응시(동점이면 최근)의 불합격 이유") MockExamFailReason bestAttemptFailReason,
        @Schema(nullable = true) LastAttempt lastAttempt
    ) {
    }

    public record LastAttempt(UUID attemptUuid, MockExamAttemptStatus status,
                              @Schema(nullable = true) Integer totalScore,
                              @Schema(nullable = true) Boolean isPassed,
                              @Schema(nullable = true) LocalDateTime submittedAt) {
    }
}
