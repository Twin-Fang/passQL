package com.passql.submission.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.CertType;
import com.passql.submission.constant.ExamAnswerRoundStatus;
import com.passql.submission.constant.MockExamAttemptStatus;
import com.passql.submission.constant.MockExamRoundStatus;
import com.passql.submission.constant.MockExamRoundType;
import com.passql.submission.dto.mockexam.MockExamHistoryResponse;
import com.passql.submission.dto.mockexam.MockExamRoundDifficultyProjection;
import com.passql.submission.dto.mockexam.MockExamRoundListResponse;
import com.passql.submission.dto.mockexam.MockExamStudySetResponse;
import com.passql.submission.dto.mockexam.MockExamRuleResponse;
import com.passql.submission.entity.ExamAnswerRound;
import com.passql.submission.entity.MockExamAnswer;
import com.passql.submission.entity.MockExamAttempt;
import com.passql.submission.entity.MockExamRound;
import com.passql.submission.entity.MockExamRoundItem;
import com.passql.submission.repository.ExamAnswerRoundRepository;
import com.passql.submission.repository.MockExamAnswerRepository;
import com.passql.submission.repository.MockExamAttemptRepository;
import com.passql.submission.repository.MockExamRoundItemRepository;
import com.passql.submission.repository.MockExamRoundRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 회원용 회차 목록·점수 추이 조회 (등급은 호출자가 isPro 로 넘김)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MockExamRoundQueryService {

    private final MockExamRoundRepository roundRepository;
    private final MockExamAttemptRepository attemptRepository;
    private final MockExamAnswerRepository answerRepository;
    private final MockExamRoundItemRepository roundItemRepository;
    private final MockExamAttemptService attemptService;
    private final ExamAnswerRoundRepository examAnswerRoundRepository;

    /** 회차 목록: 형식 > 풀이 중 응시 > 공개 회차별 시작·학습 판정·난이도·최고 점수·마지막 응시 (마감 지난 응시는 먼저 채점) */
    @Transactional
    public MockExamRoundListResponse getRoundList(UUID memberUuid, boolean isPro) {
        attemptService.finalizeMemberTimeUpAttempts(memberUuid);

        // 공개 회차 중 오늘 열린 회차만 (FINAL 은 시험일 3일 전부터, #1084)
        LocalDate today = attemptService.now().toLocalDate();
        List<MockExamRound> publishedRounds = roundRepository.findByStatusOrderByRoundNumberAsc(MockExamRoundStatus.PUBLISHED)
            .stream().filter(round -> MockExamFinalRoundSchedule.isOpen(round, today)).toList();
        Map<UUID, Double> averageDifficultyByRoundUuid = findAverageDifficultyByRoundUuid(publishedRounds);
        List<MockExamAttempt> memberAttempts = attemptRepository.findByMemberUuidOrderByStartedAtAsc(memberUuid);
        Map<UUID, MockExamRound> roundByUuid = roundRepository.findAllById(memberAttempts.stream()
                .map(MockExamAttempt::getMockExamRoundUuid).distinct().toList()).stream()
            .collect(Collectors.toMap(MockExamRound::getMockExamRoundUuid, Function.identity()));
        MockExamAttempt inProgressAttempt = memberAttempts.stream().filter(MockExamAttempt::isInProgress)
            .reduce((first, second) -> second).orElse(null);
        MockExamFreeRounds freeRounds = MockExamFreeRounds.from(publishedRounds);
        // 체험 소진 판정은 모의고사 회차 응시만 (기출 회차 응시 제외, #1079)
        boolean hasAnyMockRoundAttempt = memberAttempts.stream()
            .map(attempt -> roundByUuid.get(attempt.getMockExamRoundUuid()))
            .anyMatch(round -> round != null && round.getRoundType() == MockExamRoundType.MOCK);

        Set<Integer> gradableExamRoundNumbers = findGradableExamRoundNumbers();
        List<MockExamRoundListResponse.RoundSummary> roundSummaries = publishedRounds.stream()
            .map(round -> toRoundSummary(round, memberAttempts, isPro, freeRounds, hasAnyMockRoundAttempt, inProgressAttempt,
                averageDifficultyByRoundUuid.get(round.getMockExamRoundUuid()), gradableExamRoundNumbers))
            .toList();
        return new MockExamRoundListResponse(MockExamRuleResponse.fromRule(),
            toInProgressAttempt(inProgressAttempt, roundByUuid), roundSummaries);
    }

    /**
     * 학습 모드 문항 (#1084): 공개·열린 회차 확인 > 학습 가능 판정 > 시험 번호 순서 문제 uuid
     * 응시 기록을 만들지 않음 (풀이는 문제 상세·제출 기존 경로, 크레딧도 기존 규칙)
     */
    public MockExamStudySetResponse getStudySet(UUID memberUuid, UUID roundUuid, boolean isPro) {
        MockExamRound round = roundRepository.findById(roundUuid)
            .filter(found -> found.getStatus() == MockExamRoundStatus.PUBLISHED)
            .filter(found -> MockExamFinalRoundSchedule.isOpen(found, attemptService.now().toLocalDate()))
            .orElseThrow(() -> new CustomException(ErrorCode.MOCK_EXAM_ROUND_NOT_FOUND));
        MockExamFreeRounds freeRounds = MockExamFreeRounds.from(
            roundRepository.findByStatusOrderByRoundNumberAsc(MockExamRoundStatus.PUBLISHED));
        if (!MockExamAccessRule.canStudy(isPro, freeRounds.isFreeTrialRound(roundUuid), freeRounds.isFreePastExamRound(roundUuid))) {
            log.info("[mock exam study] rejected 403 : member={}, round={}, reason=PRO_REQUIRED", memberUuid, roundUuid);
            throw new CustomException(ErrorCode.PRO_REQUIRED);
        }
        List<UUID> questionUuids = roundItemRepository.findByMockExamRoundUuidOrderByQuestionNumberAsc(roundUuid).stream()
            .map(MockExamRoundItem::getQuestionUuid)
            .toList();
        return new MockExamStudySetResponse(roundUuid, round.getTitle(), questionUuids);
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
                                                                  boolean isPro, MockExamFreeRounds freeRounds,
                                                                  boolean hasAnyMockRoundAttempt,
                                                                  MockExamAttempt inProgressAttempt,
                                                                  Double averageDifficulty,
                                                                  Set<Integer> gradableExamRoundNumbers) {
        UUID roundUuid = round.getMockExamRoundUuid();
        boolean isFreeTrialRound = freeRounds.isFreeTrialRound(roundUuid);
        boolean isFreePastExamRound = freeRounds.isFreePastExamRound(roundUuid);
        List<MockExamAttempt> roundAttempts = memberAttempts.stream()
            .filter(attempt -> attempt.getMockExamRoundUuid().equals(roundUuid))
            .toList();
        List<MockExamAttempt> submittedAttempts = roundAttempts.stream()
            .filter(attempt -> attempt.getStatus() == MockExamAttemptStatus.SUBMITTED)
            .toList();
        MockExamAttempt bestAttempt = findBestAttempt(submittedAttempts);
        MockExamAttempt lastAttempt = roundAttempts.isEmpty() ? null : roundAttempts.get(roundAttempts.size() - 1);

        var startBlockReason = MockExamAccessRule.findStartBlockReason(isPro, isFreeTrialRound, isFreePastExamRound,
            hasAnyMockRoundAttempt, roundUuid, inProgressAttempt != null ? inProgressAttempt.getMockExamRoundUuid() : null);
        return new MockExamRoundListResponse.RoundSummary(roundUuid, round.getRoundNumber(), round.getTitle(),
            round.getRoundType(), round.getExamRoundNumberOrNull(), round.getExamDate(),
            isFreeTrialRound, isFreePastExamRound, startBlockReason == null, startBlockReason,
            MockExamAccessRule.canStudy(isPro, isFreeTrialRound, isFreePastExamRound), averageDifficulty,
            submittedAttempts.size(),
            bestAttempt == null ? null : bestAttempt.getTotalScore(),
            bestAttempt == null ? null : bestAttempt.getIsPassed(),
            bestAttempt == null ? null : bestAttempt.getFailReason(),
            lastAttempt == null ? null : new MockExamRoundListResponse.LastAttempt(lastAttempt.getMockExamAttemptUuid(),
                lastAttempt.getStatus(), lastAttempt.getTotalScore(), lastAttempt.getIsPassed(), lastAttempt.getSubmittedAt()),
            round.getRoundType() == MockExamRoundType.PAST_EXAM
                && gradableExamRoundNumbers.contains(round.getExamRoundNumberOrNull()));
    }

    /** OMR 가채점이 열린 SQLD 시험 회차 번호 (가답안 회차 중 마감 제외, 기출 회차 행의 진입 표시용) */
    private Set<Integer> findGradableExamRoundNumbers() {
        return examAnswerRoundRepository.findByCertTypeAndStatusIn(CertType.SQLD,
                List.of(ExamAnswerRoundStatus.COLLECTING, ExamAnswerRoundStatus.OFFICIAL)).stream()
            .map(ExamAnswerRound::getRoundNumber)
            .collect(Collectors.toSet());
    }

    /** 회차 uuid > 문항 평균 난이도 (회차 없으면 빈 맵) */
    private Map<UUID, Double> findAverageDifficultyByRoundUuid(List<MockExamRound> rounds) {
        if (rounds.isEmpty()) {
            return Map.of();
        }
        return roundItemRepository.findAverageDifficultyByRoundUuidIn(
                rounds.stream().map(MockExamRound::getMockExamRoundUuid).toList()).stream()
            .filter(projection -> projection.averageDifficulty() != null)
            .collect(Collectors.toMap(MockExamRoundDifficultyProjection::roundUuid,
                MockExamRoundDifficultyProjection::averageDifficulty));
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
