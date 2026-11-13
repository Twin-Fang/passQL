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
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.Clock;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 날짜별(KST) 무료 한도 보너스 조회(오늘·기간): 재료 4개 수집 > DailyFreeBonusRule 판정
 * 재료 4개: 오늘의 세트 완료 기록, 그날 배정 문제, 배정 문제 그날 제출, 광고 보너스 횟수 (기간을 재료마다 쿼리 1회로 묶어 조회)
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
        return readByDate(memberUuid, today, today).get(today);
    }

    /** 날짜별(KST) 받은 보너스 [fromDate, toDate]: 기간의 모든 날짜가 키 (날짜 오름차순) */
    public Map<LocalDate, DailyFreeBonus> readByDate(UUID memberUuid, LocalDate fromDate, LocalDate toDate) {
        // 재료 4개 (날짜별)
        Map<LocalDate, DailySetSubmission> completionByDate = dailySetSubmissionRepository
            .findByMemberUuidAndChallengeDateBetween(memberUuid, fromDate, toDate).stream()
            .collect(Collectors.toMap(DailySetSubmission::getChallengeDate, Function.identity()));
        Map<LocalDate, Set<UUID>> assignedQuestionUuidsByDate = dailyChallengeRepository
            .findByChallengeDateBetweenOrderByChallengeDateAscSortOrderAsc(fromDate, toDate).stream()
            .collect(Collectors.groupingBy(DailyChallenge::getChallengeDate,
                Collectors.mapping(DailyChallenge::getQuestionUuid, Collectors.toSet())));
        Map<LocalDate, Set<UUID>> submittedQuestionUuidsByDate =
            findSubmittedAssignedQuestionUuidsByDate(memberUuid, assignedQuestionUuidsByDate, fromDate);
        Map<LocalDate, Integer> adBonusUsedCountByDate = memberDailyAdBonusRepository
            .countGroupedByBonusDate(memberUuid, fromDate, toDate).stream()
            .collect(Collectors.toMap(DailyAdBonusCountProjection::getBonusDate,
                adBonusCount -> (int) adBonusCount.getAdBonusCount()));

        // 날짜별 판정
        Map<LocalDate, DailyFreeBonus> bonusByDate = new LinkedHashMap<>();
        for (LocalDate date = fromDate; !date.isAfter(toDate); date = date.plusDays(1)) {
            DailySetSubmission completion = completionByDate.get(date);
            bonusByDate.put(date, DailyFreeBonusRule.calculate(new DailyFreeBonusInput(
                completion != null,
                completion != null ? completion.getCorrectCount() : 0,
                assignedQuestionUuidsByDate.getOrDefault(date, Set.of()).size(),
                submittedQuestionUuidsByDate.getOrDefault(date, Set.of()).size(),
                adBonusUsedCountByDate.getOrDefault(date, 0))));
        }
        return bonusByDate;
    }

    /** 오늘 받은 광고 보너스 횟수 */
    public int countAdBonusUsedToday(UUID memberUuid) {
        return memberDailyAdBonusRepository.countByMemberUuidAndBonusDate(memberUuid, today());
    }

    /** 오늘 날짜 (KST) */
    public LocalDate today() {
        return LocalDate.now(clock);
    }

    // 날짜별 배정 문제 중 그날 제출한 서로 다른 문제 (기간 전체에 배정 없으면 조회 생략)
    private Map<LocalDate, Set<UUID>> findSubmittedAssignedQuestionUuidsByDate(
            UUID memberUuid, Map<LocalDate, Set<UUID>> assignedQuestionUuidsByDate, LocalDate fromDate) {
        Set<UUID> assignedQuestionUuids = assignedQuestionUuidsByDate.values().stream()
            .flatMap(Set::stream)
            .collect(Collectors.toSet());
        if (assignedQuestionUuids.isEmpty()) {
            return Map.of();
        }
        // 제출 > 제출 날짜에 배정된 문제만 그 날짜로 모음 (다른 날 배정 문제 제출은 세지 않음)
        Map<LocalDate, Set<UUID>> submittedQuestionUuidsByDate = new HashMap<>();
        for (Submission submission : submissionRepository
                .findByMemberUuidAndQuestionUuidInAndSubmittedAtGreaterThanEqualOrderBySubmittedAtAsc(
                    memberUuid, assignedQuestionUuids, fromDate.atStartOfDay())) {
            LocalDate submittedDate = submission.getSubmittedAt().toLocalDate();
            if (assignedQuestionUuidsByDate.getOrDefault(submittedDate, Set.of()).contains(submission.getQuestionUuid())) {
                submittedQuestionUuidsByDate.computeIfAbsent(submittedDate, date -> new HashSet<>())
                    .add(submission.getQuestionUuid());
            }
        }
        return submittedQuestionUuidsByDate;
    }
}
