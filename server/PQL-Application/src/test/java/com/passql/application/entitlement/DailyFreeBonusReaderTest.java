package com.passql.application.entitlement;

import com.passql.common.util.ServiceTimeZone;
import com.passql.member.repository.DailyAdBonusCountProjection;
import com.passql.member.repository.MemberDailyAdBonusRepository;
import com.passql.question.entity.DailyChallenge;
import com.passql.question.entity.DailySetSubmission;
import com.passql.question.repository.DailyChallengeRepository;
import com.passql.question.repository.DailySetSubmissionRepository;
import com.passql.submission.entity.Submission;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * 날짜별 보너스 (#974): 오늘 판정과 내역이 함께 쓰는 재료 수집 (그날 배정 문제를 그날 제출한 것만 완료로 인정)
 */
class DailyFreeBonusReaderTest {

    private static final UUID MEMBER_UUID = UUID.randomUUID();
    private static final LocalDate TODAY = LocalDate.of(2026, 11, 12);
    private static final LocalDate YESTERDAY = TODAY.minusDays(1);

    private final DailySetSubmissionRepository dailySetSubmissionRepository = mock(DailySetSubmissionRepository.class);
    private final DailyChallengeRepository dailyChallengeRepository = mock(DailyChallengeRepository.class);
    private final SubmissionRepository submissionRepository = mock(SubmissionRepository.class);
    private final MemberDailyAdBonusRepository memberDailyAdBonusRepository = mock(MemberDailyAdBonusRepository.class);
    private final DailyFreeBonusReader dailyFreeBonusReader = new DailyFreeBonusReader(
        dailySetSubmissionRepository, dailyChallengeRepository, submissionRepository, memberDailyAdBonusRepository,
        Clock.fixed(TODAY.atTime(9, 0).atZone(ServiceTimeZone.ZONE).toInstant(), ServiceTimeZone.ZONE));

    @Test
    void 날짜마다_그날_재료로_보너스를_판정한다() {
        // 어제: 배정 1문제를 어제 제출·완료(1/1 정답) + 광고 2회 / 오늘: 배정 문제를 아직 안 냄(어제 문제만 다시 냄)
        UUID yesterdaysQuestion = UUID.randomUUID();
        UUID todaysQuestion = UUID.randomUUID();
        when(dailyChallengeRepository.findByChallengeDateBetweenOrderByChallengeDateAscSortOrderAsc(YESTERDAY, TODAY))
            .thenReturn(List.of(toDailyChallenge(YESTERDAY, yesterdaysQuestion), toDailyChallenge(TODAY, todaysQuestion)));
        when(dailySetSubmissionRepository.findByMemberUuidAndChallengeDateBetween(MEMBER_UUID, YESTERDAY, TODAY))
            .thenReturn(List.of(
                toCompletion(YESTERDAY, 1),
                // 오늘 완료 기록이 있어도 배정 문제를 오늘 제출하지 않았으면 완료 보너스 없음
                toCompletion(TODAY, 0)));
        when(submissionRepository.findByMemberUuidAndQuestionUuidInAndSubmittedAtGreaterThanEqualOrderBySubmittedAtAsc(
            MEMBER_UUID, Set.of(yesterdaysQuestion, todaysQuestion), YESTERDAY.atStartOfDay()))
            .thenReturn(List.of(
                toSubmission(yesterdaysQuestion, YESTERDAY.atTime(10, 0)),
                toSubmission(yesterdaysQuestion, TODAY.atTime(8, 0))));
        // 목 안에서 다른 목을 만들면 스터빙이 끊기므로 먼저 만든다
        DailyAdBonusCountProjection yesterdaysAdBonusCount = toAdBonusCount(YESTERDAY, 2);
        when(memberDailyAdBonusRepository.countGroupedByBonusDate(MEMBER_UUID, YESTERDAY, TODAY))
            .thenReturn(List.of(yesterdaysAdBonusCount));

        Map<LocalDate, DailyFreeBonus> bonusByDate = dailyFreeBonusReader.readByDate(MEMBER_UUID, YESTERDAY, TODAY);

        assertThat(bonusByDate).containsExactly(
            Map.entry(YESTERDAY, new DailyFreeBonus(true, true, 2, 3, DailyFreeBonusRule.BONUS_QUESTION_COUNT)),
            Map.entry(TODAY, new DailyFreeBonus(false, false, 0, 1, DailyFreeBonusRule.BONUS_QUESTION_COUNT)));
    }

    private static DailyChallenge toDailyChallenge(LocalDate challengeDate, UUID questionUuid) {
        return DailyChallenge.builder().challengeDate(challengeDate).sortOrder(0).questionUuid(questionUuid).build();
    }

    private static DailySetSubmission toCompletion(LocalDate challengeDate, int correctCount) {
        return DailySetSubmission.builder()
            .memberUuid(MEMBER_UUID).challengeDate(challengeDate).correctCount(correctCount)
            .completedAt(challengeDate.atTime(12, 0)).build();
    }

    private static Submission toSubmission(UUID questionUuid, LocalDateTime submittedAt) {
        return Submission.builder().memberUuid(MEMBER_UUID).questionUuid(questionUuid).submittedAt(submittedAt).build();
    }

    private static DailyAdBonusCountProjection toAdBonusCount(LocalDate bonusDate, long adBonusCount) {
        DailyAdBonusCountProjection projection = mock(DailyAdBonusCountProjection.class);
        when(projection.getBonusDate()).thenReturn(bonusDate);
        when(projection.getAdBonusCount()).thenReturn(adBonusCount);
        return projection;
    }
}
