package com.passql.application.entitlement;

import com.passql.question.entity.DailyChallenge;
import com.passql.question.repository.DailyChallengeRepository;
import com.passql.submission.repository.SubmissionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 하루 문제 수 계산: KST 오늘 구간 제출 문제 수, 오늘의 문제 배정 여부
 * 오늘 구간 [00:00, 다음날 00:00) 에서 오늘의 문제 배정분을 뺀 서로 다른 문제 수
 */
@Component
public class DailyQuestionCounter {

    private final SubmissionRepository submissionRepository;
    private final DailyChallengeRepository dailyChallengeRepository;
    private final Clock clock;

    @Autowired
    public DailyQuestionCounter(SubmissionRepository submissionRepository,
                                DailyChallengeRepository dailyChallengeRepository) {
        this(submissionRepository, dailyChallengeRepository, Clock.system(FeatureAccessPolicy.SERVICE_ZONE));
    }

    DailyQuestionCounter(SubmissionRepository submissionRepository,
                         DailyChallengeRepository dailyChallengeRepository, Clock clock) {
        this.submissionRepository = submissionRepository;
        this.dailyChallengeRepository = dailyChallengeRepository;
        this.clock = clock;
    }

    /** 오늘(KST) 제출한 서로 다른 문제 수, 오늘의 문제 배정분 제외 */
    public int countTodayRandomSolved(UUID memberUuid) {
        LocalDate today = LocalDate.now(clock);
        LocalDateTime dayStart = today.atStartOfDay();
        LocalDateTime nextDayStart = today.plusDays(1).atStartOfDay();

        // 제외 목록이 비면 NOT IN 을 쓰지 않는 쿼리로 분기
        Set<UUID> excludedQuestionUuids = findTodaysDailyChallengeQuestionUuids(today);
        if (excludedQuestionUuids.isEmpty()) {
            return (int) submissionRepository.countDistinctQuestionsSubmittedBetween(memberUuid, dayStart, nextDayStart);
        }
        return (int) submissionRepository.countDistinctQuestionsSubmittedBetweenExcluding(
            memberUuid, dayStart, nextDayStart, excludedQuestionUuids);
    }

    /** 오늘의 문제로 배정된 문제인지 (앱 "오늘의 문제" 와 같은 daily_challenge 기준) */
    public boolean isTodaysDailyChallengeQuestion(UUID questionUuid) {
        return findTodaysDailyChallengeQuestionUuids(LocalDate.now(clock)).contains(questionUuid);
    }

    private Set<UUID> findTodaysDailyChallengeQuestionUuids(LocalDate today) {
        return dailyChallengeRepository.findByChallengeDateOrderBySortOrderAsc(today).stream()
            .map(DailyChallenge::getQuestionUuid)
            .collect(Collectors.toSet());
    }
}
