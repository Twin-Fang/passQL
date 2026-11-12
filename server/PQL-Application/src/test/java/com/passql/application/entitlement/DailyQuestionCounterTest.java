package com.passql.application.entitlement;

import com.passql.common.util.ServiceTimeZone;
import com.passql.question.entity.DailyChallenge;
import com.passql.question.repository.DailyChallengeRepository;
import com.passql.submission.dto.SubmittedQuestionProjection;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * 날짜별 랜덤 풀이 수 (#974): 오늘 판정과 내역이 함께 쓰는 계산 (그날 배정분 제외, 같은 문제 1건, 날짜 분리)
 */
class DailyQuestionCounterTest {

    private static final UUID MEMBER_UUID = UUID.randomUUID();
    private static final LocalDate TODAY = LocalDate.of(2026, 11, 12);
    private static final LocalDate YESTERDAY = TODAY.minusDays(1);

    private final SubmissionRepository submissionRepository = mock(SubmissionRepository.class);
    private final DailyChallengeRepository dailyChallengeRepository = mock(DailyChallengeRepository.class);
    private final DailyQuestionCounter dailyQuestionCounter = new DailyQuestionCounter(
        submissionRepository, dailyChallengeRepository,
        Clock.fixed(TODAY.atTime(9, 0).atZone(ServiceTimeZone.ZONE).toInstant(), ServiceTimeZone.ZONE));

    @Test
    void 그날_배정된_오늘의_문제는_빼고_날짜별로_서로_다른_문제를_센다() {
        UUID yesterdaysChallengeQuestion = UUID.randomUUID();
        UUID randomQuestionA = UUID.randomUUID();
        UUID randomQuestionB = UUID.randomUUID();
        when(dailyChallengeRepository.findByChallengeDateBetweenOrderByChallengeDateAscSortOrderAsc(YESTERDAY, TODAY))
            .thenReturn(List.of(DailyChallenge.builder()
                .challengeDate(YESTERDAY).sortOrder(0).questionUuid(yesterdaysChallengeQuestion).build()));
        when(submissionRepository.findQuestionsSubmittedBetween(
            MEMBER_UUID, YESTERDAY.atStartOfDay(), TODAY.plusDays(1).atStartOfDay()))
            .thenReturn(List.of(
                // 어제: 배정 문제(제외), A 두 번(1건), B
                new SubmittedQuestionProjection(yesterdaysChallengeQuestion, YESTERDAY.atTime(8, 0)),
                new SubmittedQuestionProjection(randomQuestionA, YESTERDAY.atTime(9, 0)),
                new SubmittedQuestionProjection(randomQuestionA, YESTERDAY.atTime(9, 5)),
                new SubmittedQuestionProjection(randomQuestionB, YESTERDAY.atTime(23, 59)),
                // 오늘: 어제 배정 문제는 오늘 배정분이 아니므로 셈
                new SubmittedQuestionProjection(yesterdaysChallengeQuestion, TODAY.atStartOfDay())));

        Map<LocalDate, Integer> randomSolvedCountByDate =
            dailyQuestionCounter.countRandomSolvedByDate(MEMBER_UUID, YESTERDAY, TODAY);

        assertThat(randomSolvedCountByDate).containsOnly(Map.entry(YESTERDAY, 2), Map.entry(TODAY, 1));
    }

    @Test
    void 오늘_수는_날짜별_계산의_오늘_값과_같다() {
        UUID todaysChallengeQuestion = UUID.randomUUID();
        when(dailyChallengeRepository.findByChallengeDateBetweenOrderByChallengeDateAscSortOrderAsc(TODAY, TODAY))
            .thenReturn(List.of(DailyChallenge.builder()
                .challengeDate(TODAY).sortOrder(0).questionUuid(todaysChallengeQuestion).build()));
        when(submissionRepository.findQuestionsSubmittedBetween(
            MEMBER_UUID, TODAY.atStartOfDay(), TODAY.plusDays(1).atStartOfDay()))
            .thenReturn(List.of(
                new SubmittedQuestionProjection(todaysChallengeQuestion, TODAY.atTime(8, 0)),
                new SubmittedQuestionProjection(UUID.randomUUID(), TODAY.atTime(8, 30))));

        assertThat(dailyQuestionCounter.countTodayRandomSolved(MEMBER_UUID)).isEqualTo(1);
        assertThat(dailyQuestionCounter.isTodaysDailyChallengeQuestion(todaysChallengeQuestion)).isTrue();
    }
}
