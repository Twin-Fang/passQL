package com.passql.submission.service;

import com.passql.submission.constant.MockExamAttemptStatus;
import com.passql.submission.constant.MockExamRoundStatus;
import com.passql.submission.dto.mockexam.MockExamHistoryResponse;
import com.passql.submission.dto.mockexam.MockExamRoundListResponse;
import com.passql.submission.dto.mockexam.MockExamRuleResponse;
import com.passql.submission.entity.MockExamAnswer;
import com.passql.submission.entity.MockExamAttempt;
import com.passql.submission.entity.MockExamRound;
import com.passql.submission.repository.MockExamAnswerRepository;
import com.passql.submission.repository.MockExamAttemptRepository;
import com.passql.submission.repository.MockExamRoundRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 회원용 회차 목록·점수 추이 조회 (등급은 호출자가 isPro 로 넘김)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MockExamRoundQueryService {

    private final MockExamRoundRepository roundRepository;
    private final MockExamAttemptRepository attemptRepository;
    private final MockExamAnswerRepository answerRepository;
    private final MockExamAttemptService attemptService;

    /** 회차 목록: 형식 > 풀이 중 응시 > 공개 회차별 시작 판정·최고 점수·마지막 응시 (마감 지난 응시는 먼저 채점) */
    @Transactional
    public MockExamRoundListResponse getRoundList(UUID memberUuid, boolean isPro) {
        attemptService.finalizeMemberTimeUpAttempts(memberUuid);

        List<MockExamRound> publishedRounds = roundRepository.findByStatusOrderByRoundNumberAsc(MockExamRoundStatus.PUBLISHED);
        List<MockExamAttempt> memberAttempts = attemptRepository.findByMemberUuidOrderByStartedAtAsc(memberUuid);
        Map<UUID, MockExamRound> roundByUuid = roundRepository.findAllById(memberAttempts.stream()
                .map(MockExamAttempt::getMockExamRoundUuid).distinct().toList()).stream()
            .collect(Collectors.toMap(MockExamRound::getMockExamRoundUuid, Function.identity()));
        MockExamAttempt inProgressAttempt = memberAttempts.stream().filter(MockExamAttempt::isInProgress)
            .reduce((first, second) -> second).orElse(null);
        UUID freeTrialRoundUuid = publishedRounds.isEmpty() ? null : publishedRounds.get(0).getMockExamRoundUuid();
        boolean hasAnyAttempt = !memberAttempts.isEmpty();

        List<MockExamRoundListResponse.RoundSummary> roundSummaries = publishedRounds.stream()
            .map(round -> toRoundSummary(round, memberAttempts, isPro, round.getMockExamRoundUuid().equals(freeTrialRoundUuid),
                hasAnyAttempt, inProgressAttempt))
            .toList();
        return new MockExamRoundListResponse(MockExamRuleResponse.fromRule(),
            toInProgressAttempt(inProgressAttempt, roundByUuid), roundSummaries);
    }

    /** 점수 추이: 채점된 응시 제출 시간순 */
    public MockExamHistoryResponse getHistory(UUID memberUuid) {
        List<MockExamAttempt> submittedAttempts = attemptRepository
            .findByMemberUuidAndStatusOrderBySubmittedAtAsc(memberUuid, MockExamAttemptStatus.SUBMITTED);
        Map<UUID, MockExamRound> roundByUuid = roundRepository.findAllById(submittedAttempts.stream()
                .map(MockExamAttempt::getMockExamRoundUuid).distinct().toList()).stream()
            .collect(Collectors.toMap(MockExamRound::getMockExamRoundUuid, Function.identity()));
        List<MockExamHistoryResponse.HistoryEntry> entries = submittedAttempts.stream()
            .map(attempt -> {
                MockExamRound round = roundByUuid.get(attempt.getMockExamRoundUuid());
                return new MockExamHistoryResponse.HistoryEntry(attempt.getMockExamAttemptUuid(),
                    round != null ? round.getRoundNumber() : 0, round != null ? round.getTitle() : "",
                    attempt.getSubmittedAt(), attempt.getTotalScore(),
                    attempt.getSubjectOneCorrectCount() * MockExamRule.POINTS_PER_QUESTION,
                    attempt.getSubjectTwoCorrectCount() * MockExamRule.POINTS_PER_QUESTION,
                    Boolean.TRUE.equals(attempt.getIsPassed()), attempt.getFailReason());
            })
            .toList();
        return new MockExamHistoryResponse(MockExamRule.PASS_SCORE, entries);
    }

    private MockExamRoundListResponse.RoundSummary toRoundSummary(MockExamRound round, List<MockExamAttempt> memberAttempts,
                                                                  boolean isPro, boolean isFreeTrialRound,
                                                                  boolean hasAnyAttempt, MockExamAttempt inProgressAttempt) {
        UUID roundUuid = round.getMockExamRoundUuid();
        List<MockExamAttempt> roundAttempts = memberAttempts.stream()
            .filter(attempt -> attempt.getMockExamRoundUuid().equals(roundUuid))
            .toList();
        List<MockExamAttempt> submittedAttempts = roundAttempts.stream()
            .filter(attempt -> attempt.getStatus() == MockExamAttemptStatus.SUBMITTED)
            .toList();
        MockExamAttempt bestAttempt = findBestAttempt(submittedAttempts);
        MockExamAttempt lastAttempt = roundAttempts.isEmpty() ? null : roundAttempts.get(roundAttempts.size() - 1);

        var startBlockReason = MockExamAccessRule.findStartBlockReason(isPro, isFreeTrialRound, hasAnyAttempt, roundUuid,
            inProgressAttempt != null ? inProgressAttempt.getMockExamRoundUuid() : null);
        return new MockExamRoundListResponse.RoundSummary(roundUuid, round.getRoundNumber(), round.getTitle(),
            isFreeTrialRound, startBlockReason == null, startBlockReason, submittedAttempts.size(),
            bestAttempt == null ? null : bestAttempt.getTotalScore(),
            bestAttempt == null ? null : bestAttempt.getIsPassed(),
            bestAttempt == null ? null : bestAttempt.getFailReason(),
            lastAttempt == null ? null : new MockExamRoundListResponse.LastAttempt(lastAttempt.getMockExamAttemptUuid(),
                lastAttempt.getStatus(), lastAttempt.getTotalScore(), lastAttempt.getIsPassed(), lastAttempt.getSubmittedAt()));
    }

    /** 최고 점수 응시 (동점이면 나중 응시, 시작 시간순 목록 기준) */
    private MockExamAttempt findBestAttempt(List<MockExamAttempt> submittedAttempts) {
        return submittedAttempts.stream()
            .filter(attempt -> attempt.getTotalScore() != null)
            .reduce((best, next) -> next.getTotalScore() >= best.getTotalScore() ? next : best)
            .orElse(null);
    }

    private MockExamRoundListResponse.InProgressAttempt toInProgressAttempt(MockExamAttempt inProgressAttempt,
                                                                           Map<UUID, MockExamRound> roundByUuid) {
        if (inProgressAttempt == null) {
            return null;
        }
        MockExamRound round = roundByUuid.get(inProgressAttempt.getMockExamRoundUuid());
        long answeredCount = answerRepository.findByMockExamAttemptUuid(inProgressAttempt.getMockExamAttemptUuid()).stream()
            .map(MockExamAnswer::getSelectedChoiceKey)
            .filter(Objects::nonNull)
            .count();
        return new MockExamRoundListResponse.InProgressAttempt(inProgressAttempt.getMockExamAttemptUuid(),
            inProgressAttempt.getMockExamRoundUuid(), round != null ? round.getRoundNumber() : 0,
            round != null ? round.getTitle() : "",
            MockExamTimer.remainingSeconds(inProgressAttempt.getDeadlineAt(), attemptService.now()), (int) answeredCount);
    }
}
