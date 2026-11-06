package com.passql.application.entitlement;

import com.passql.common.util.ServiceTimeZone;
import com.passql.member.repository.MemberDailyAdBonusRepository;
import com.passql.question.entity.DailyChallenge;
import com.passql.question.entity.DailySetSubmission;
import com.passql.question.repository.DailyChallengeRepository;
import com.passql.question.repository.DailySetSubmissionRepository;
import com.passql.submission.entity.Submission;
import com.passql.submission.repository.SubmissionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.Clock;
import java.time.LocalDate;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 오늘(KST) 무료 한도 보너스 조회: 재료 4개 수집 > DailyFreeBonusRule 판정
 * 재료 4개: 오늘의 세트 완료 기록, 오늘 배정 문제, 배정 문제 오늘 제출, 광고 보너스 횟수
 */
@Component
public class DailyFreeBonusReader {

    private final DailySetSubmissionRepository dailySetSubmissionRepository;
    private final DailyChallengeRepository dailyChallengeRepository;
    private final SubmissionRepository submissionRepository;
    private final MemberDailyAdBonusRepository memberDailyAdBonusRepository;
    private final Clock clock;

    @Autowired
    public DailyFreeBonusReader(DailySetSubmissionRepository dailySetSubmissionRepository,
                                DailyChallengeRepository dailyChallengeRepository,
                                SubmissionRepository submissionRepository,
                                MemberDailyAdBonusRepository memberDailyAdBonusRepository) {
        this(dailySetSubmissionRepository, dailyChallengeRepository, submissionRepository,
            memberDailyAdBonusRepository, Clock.system(ServiceTimeZone.ZONE));
    }

    DailyFreeBonusReader(DailySetSubmissionRepository dailySetSubmissionRepository,
                         DailyChallengeRepository dailyChallengeRepository,
                         SubmissionRepository submissionRepository,
                         MemberDailyAdBonusRepository memberDailyAdBonusRepository, Clock clock) {
        this.dailySetSubmissionRepository = dailySetSubmissionRepository;
        this.dailyChallengeRepository = dailyChallengeRepository;
        this.submissionRepository = submissionRepository;
        this.memberDailyAdBonusRepository = memberDailyAdBonusRepository;
        this.clock = clock;
    }

    /** 오늘 받은 보너스 */
    public DailyFreeBonus readToday(UUID memberUuid) {
        LocalDate today = today();
        Optional<DailySetSubmission> completion = dailySetSubmissionRepository.findByMemberUuidAndChallengeDate(memberUuid, today);
        Set<UUID> assignedQuestionUuids = dailyChallengeRepository.findByChallengeDateOrderBySortOrderAsc(today).stream()
            .map(DailyChallenge::getQuestionUuid)
            .collect(Collectors.toSet());
        return DailyFreeBonusRule.calculate(new DailyFreeBonusInput(
            completion.isPresent(),
            completion.map(DailySetSubmission::getCorrectCount).orElse(0),
            assignedQuestionUuids.size(),
            countSubmittedToday(memberUuid, assignedQuestionUuids, today),
            countAdBonusUsedToday(memberUuid)));
    }

    /** 오늘 받은 광고 보너스 횟수 */
    public int countAdBonusUsedToday(UUID memberUuid) {
        return memberDailyAdBonusRepository.countByMemberUuidAndBonusDate(memberUuid, today());
    }

    /** 오늘 날짜 (KST) */
    public LocalDate today() {
        return LocalDate.now(clock);
    }

    // 배정 문제 중 오늘 제출한 서로 다른 문제 수 (배정 없으면 조회 생략)
    private int countSubmittedToday(UUID memberUuid, Set<UUID> assignedQuestionUuids, LocalDate today) {
        if (assignedQuestionUuids.isEmpty()) {
            return 0;
        }
        return (int) submissionRepository
            .findByMemberUuidAndQuestionUuidInAndSubmittedAtGreaterThanEqualOrderBySubmittedAtAsc(
                memberUuid, assignedQuestionUuids, today.atStartOfDay())
            .stream()
            .map(Submission::getQuestionUuid)
            .distinct()
            .count();
    }
}
