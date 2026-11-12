package com.passql.application.entitlement;

import com.passql.common.util.ServiceTimeZone;
import com.passql.question.entity.DailyChallenge;
import com.passql.question.repository.DailyChallengeRepository;
import com.passql.submission.dto.SubmittedQuestionProjection;
import com.passql.submission.repository.SubmissionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.Clock;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 하루 문제 수 계산: KST 날짜별 제출 문제 수(오늘·기간), 오늘의 문제 배정 여부
 * 날짜 구간 [00:00, 다음날 00:00) 에서 그날 오늘의 문제 배정분을 뺀 서로 다른 문제 수
 */
@Component
public class DailyQuestionCounter {

    private final SubmissionRepository submissionRepository;
    private final DailyChallengeRepository dailyChallengeRepository;
    private final Clock clock;

    @Autowired
    public DailyQuestionCounter(SubmissionRepository submissionRepository,
                                DailyChallengeRepository dailyChallengeRepository) {
        this(submissionRepository, dailyChallengeRepository, Clock.system(ServiceTimeZone.ZONE));
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
        return countRandomSolvedByDate(memberUuid, today, today).getOrDefault(today, 0);
    }

    /**
     * 날짜별(KST) 제출한 서로 다른 문제 수 [fromDate, toDate]: 그날 오늘의 문제 배정분·모의고사 제출 제외
     * 기간을 쿼리 2회로 묶어 조회, 센 문제가 없는 날은 키 없음
     */
    public Map<LocalDate, Integer> countRandomSolvedByDate(UUID memberUuid, LocalDate fromDate, LocalDate toDate) {
        Map<LocalDate, Set<UUID>> excludedQuestionUuidsByDate = findDailyChallengeQuestionUuidsByDate(fromDate, toDate);

        // 제출 > 제출 날짜별 서로 다른 문제 (그날 배정분 제외)
        Map<LocalDate, Set<UUID>> solvedQuestionUuidsByDate = new HashMap<>();
        for (SubmittedQuestionProjection submission : submissionRepository.findQuestionsSubmittedBetween(
                memberUuid, fromDate.atStartOfDay(), toDate.plusDays(1).atStartOfDay())) {
            LocalDate submittedDate = submission.submittedAt().toLocalDate();
            if (excludedQuestionUuidsByDate.getOrDefault(submittedDate, Set.of()).contains(submission.questionUuid())) {
                continue;
            }
            solvedQuestionUuidsByDate.computeIfAbsent(submittedDate, date -> new HashSet<>()).add(submission.questionUuid());
        }
        return solvedQuestionUuidsByDate.entrySet().stream()
            .collect(Collectors.toMap(Map.Entry::getKey, entry -> entry.getValue().size()));
    }

    /** 오늘의 문제로 배정된 문제인지 (앱 "오늘의 문제" 와 같은 daily_challenge 기준) */
    public boolean isTodaysDailyChallengeQuestion(UUID questionUuid) {
        LocalDate today = LocalDate.now(clock);
        return findDailyChallengeQuestionUuidsByDate(today, today).getOrDefault(today, Set.of()).contains(questionUuid);
    }

    // 날짜별 오늘의 문제 배정 문제 [fromDate, toDate] (배정 없는 날은 키 없음)
    private Map<LocalDate, Set<UUID>> findDailyChallengeQuestionUuidsByDate(LocalDate fromDate, LocalDate toDate) {
        return dailyChallengeRepository.findByChallengeDateBetweenOrderByChallengeDateAscSortOrderAsc(fromDate, toDate).stream()
            .collect(Collectors.groupingBy(DailyChallenge::getChallengeDate,
                Collectors.mapping(DailyChallenge::getQuestionUuid, Collectors.toSet())));
    }
}
