package com.passql.application.entitlement;

import com.passql.question.entity.DailyChallenge;
import com.passql.question.repository.DailyChallengeRepository;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 오늘 랜덤 푼 문제 수: KST 하루 구간 조회, 오늘의 문제 배정 제외, 제외 목록이 비면 제외 없는 조회로 분기
 * 서로 다른 문제 수 집계와 경계(< 다음날 0시) 쿼리 자체는 SubmissionDailyCountRepositoryPostgresTest 가 실 DB 로 검증
 */
class SubmissionDailyCountTest {

    private static final ZoneId SEOUL = ZoneId.of("Asia/Seoul");
    // 고정 현재 시각: 2026-10-22 23:59:30 KST (자정 직전)
    private static final LocalDateTime JUST_BEFORE_MIDNIGHT = LocalDateTime.of(2026, 10, 22, 23, 59, 30);

    private final SubmissionRepository submissionRepository = mock(SubmissionRepository.class);
    private final DailyChallengeRepository dailyChallengeRepository = mock(DailyChallengeRepository.class);
    private final UUID memberUuid = UUID.randomUUID();

    private DailyQuestionCounter counterAt(LocalDateTime nowKst) {
        Clock clock = Clock.fixed(nowKst.atZone(SEOUL).toInstant(), SEOUL);
        return new DailyQuestionCounter(submissionRepository, dailyChallengeRepository, clock);
    }

    private DailyChallenge challengeOf(UUID questionUuid) {
        DailyChallenge challenge = mock(DailyChallenge.class);
        when(challenge.getQuestionUuid()).thenReturn(questionUuid);
        return challenge;
    }

    @Test
    void kstMidnightBoundary() {
        // 10-22 23:59 KST 제출은 10-22 구간에만 속하고 10-23 구간에는 들어가지 않음
        when(dailyChallengeRepository.findByChallengeDateOrderBySortOrderAsc(LocalDate.of(2026, 10, 22)))
            .thenReturn(List.of());
        LocalDateTime dayStart = LocalDateTime.of(2026, 10, 22, 0, 0);
        LocalDateTime nextDayStart = LocalDateTime.of(2026, 10, 23, 0, 0);
        when(submissionRepository.countDistinctQuestionsSubmittedBetween(memberUuid, dayStart, nextDayStart))
            .thenReturn(4L);

        assertThat(counterAt(JUST_BEFORE_MIDNIGHT).countTodayRandomSolved(memberUuid)).isEqualTo(4);

        // 자정 지나 10-23 이 되면 구간이 [10-23 00:00, 10-24 00:00) 로 바뀌어 이전 제출은 세지 않음
        when(dailyChallengeRepository.findByChallengeDateOrderBySortOrderAsc(LocalDate.of(2026, 10, 23)))
            .thenReturn(List.of());
        when(submissionRepository.countDistinctQuestionsSubmittedBetween(
            memberUuid, nextDayStart, LocalDateTime.of(2026, 10, 24, 0, 0))).thenReturn(0L);

        assertThat(counterAt(LocalDateTime.of(2026, 10, 23, 0, 0, 1)).countTodayRandomSolved(memberUuid)).isZero();
    }

    @Test
    void sameQuestionResubmitted_countsOnce() {
        // 서로 다른 문제 수 집계는 쿼리(COUNT DISTINCT)가 맡고 카운터는 그 값을 그대로 돌려줌
        when(dailyChallengeRepository.findByChallengeDateOrderBySortOrderAsc(any())).thenReturn(List.of());
        when(submissionRepository.countDistinctQuestionsSubmittedBetween(any(), any(), any())).thenReturn(1L);

        assertThat(counterAt(JUST_BEFORE_MIDNIGHT).countTodayRandomSolved(memberUuid)).isEqualTo(1);
    }

    @Test
    void todaysDailyChallengeQuestion_notCounted() {
        UUID dailyQuestionUuid = UUID.randomUUID();
        List<DailyChallenge> todaysChallenges = List.of(challengeOf(dailyQuestionUuid));
        when(dailyChallengeRepository.findByChallengeDateOrderBySortOrderAsc(LocalDate.of(2026, 10, 22)))
            .thenReturn(todaysChallenges);
        when(submissionRepository.countDistinctQuestionsSubmittedBetween(any(), any(), any())).thenReturn(99L);
        when(submissionRepository.countDistinctQuestionsSubmittedBetweenExcluding(
            memberUuid, LocalDateTime.of(2026, 10, 22, 0, 0), LocalDateTime.of(2026, 10, 23, 0, 0),
            Set.of(dailyQuestionUuid))).thenReturn(3L);

        assertThat(counterAt(JUST_BEFORE_MIDNIGHT).countTodayRandomSolved(memberUuid)).isEqualTo(3);
        // 배정 문제가 있으면 제외 쿼리만 쓰고 제외 없는 쿼리는 부르지 않음
        verify(submissionRepository, never()).countDistinctQuestionsSubmittedBetween(any(), any(), any());
    }

    @Test
    void noDailyChallengeToday_usesQueryWithoutExclusion() {
        // 빈 컬렉션 NOT IN 은 JPA 구현체별로 위험해 제외 없는 쿼리로 분기
        when(dailyChallengeRepository.findByChallengeDateOrderBySortOrderAsc(any())).thenReturn(List.of());
        when(submissionRepository.countDistinctQuestionsSubmittedBetween(any(), any(), any())).thenReturn(2L);

        assertThat(counterAt(JUST_BEFORE_MIDNIGHT).countTodayRandomSolved(memberUuid)).isEqualTo(2);
        verify(submissionRepository, never()).countDistinctQuestionsSubmittedBetweenExcluding(any(), any(), any(), any());
    }

    @Test
    void isTodaysDailyChallengeQuestion_checksTodaysAssignedList() {
        UUID dailyQuestionUuid = UUID.randomUUID();
        List<DailyChallenge> todaysChallenges = List.of(challengeOf(dailyQuestionUuid));
        when(dailyChallengeRepository.findByChallengeDateOrderBySortOrderAsc(LocalDate.of(2026, 10, 22)))
            .thenReturn(todaysChallenges);

        DailyQuestionCounter counter = counterAt(JUST_BEFORE_MIDNIGHT);
        assertThat(counter.isTodaysDailyChallengeQuestion(dailyQuestionUuid)).isTrue();
        assertThat(counter.isTodaysDailyChallengeQuestion(UUID.randomUUID())).isFalse();
    }
}
