package com.passql.application.service.statsanalysis;

import com.passql.application.concept.ConceptLearningService;
import com.passql.application.concept.dto.ConceptTopicSummary;
import com.passql.application.service.statsanalysis.StatsAnalysisPromptFormatter.SubtopicStat;
import com.passql.application.service.statsanalysis.StatsAnalysisPromptFormatter.WrongQuestionSummary;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.TopicRepository;
import com.passql.meta.service.ExamScheduleService;
import com.passql.submission.repository.StatsAnalysisQueryRepository;
import com.passql.submission.repository.SubmissionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 통계 AI 분석 데이터 조회 (#861, #862): 판정 입력(토픽 수치·2주 집계·시험 일수·오답 수·반복 오답·개념 단원) + 프롬프트 재료(세부 주제·최근 오답)
 * 토픽 수치는 최근 90일 누적 (문제별 마지막 시도), 통계 화면 토픽 표(최근 7일)보다 길게 > 며칠 쉬어도 약점 유지
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class StatsAnalysisDataLoader {

    // 1과목(데이터 모델링의 이해) 토픽 코드 (topic.code, V0_0_21 시드 — 표시 이름은 바뀔 수 있어 코드로 판정)
    static final String SUBJECT_ONE_TOPIC_CODE = "data_modeling";
    // 약점 판정·세부 주제·반복 오답 수치 기간 (일, 시험 준비 기간을 덮는 누적, 화면 "최근 90일 기준" 표기)
    static final int ANALYSIS_STATS_RECENT_DAYS = 90;
    private static final int DAYS_PER_WEEK = 7;
    // 프롬프트에 넣는 세부 주제 최소 풀이 수, 최근 오답 최대 건수
    private static final int MIN_SUBTOPIC_SOLVED_COUNT = 3;
    private static final int MAX_RECENT_WRONG_COUNT = 8;
    // 반복 오답: 같은 문제 오답 횟수 기준
    static final int REPEATED_WRONG_MIN_WRONG_COUNT = 2;

    private final TopicRepository topicRepository;
    private final SubmissionRepository submissionRepository;
    private final StatsAnalysisQueryRepository statsAnalysisQueryRepository;
    private final ExamScheduleService examScheduleService;
    private final ConceptLearningService conceptLearningService;

    /** 판정 입력 조회 (토픽 정렬 순서 유지) */
    public StatsAnalysisInput loadInput(UUID memberUuid) {
        return new StatsAnalysisInput(
                loadTopicStats(memberUuid),
                submissionRepository.countByMemberUuid(memberUuid),
                loadTwoWeekCounts(memberUuid),
                findDaysUntilExam(),
                statsAnalysisQueryRepository.countLatestWrongQuestions(memberUuid.toString()),
                loadRepeatedWrongStat(memberUuid),
                findOpenConceptTopicUuids(memberUuid)
        );
    }

    /** 반복 오답 집계: 문제 수, 마지막 시도도 오답인 수, 절반 넘게 몰린 토픽 (최근 90일) */
    private RepeatedWrongStat loadRepeatedWrongStat(UUID memberUuid) {
        LocalDateTime since = LocalDateTime.now().minusDays(ANALYSIS_STATS_RECENT_DAYS);
        // Object[] = { topicName, latestIsCorrect }
        List<Object[]> rows = statsAnalysisQueryRepository.findRepeatedWrongQuestionsAfter(
                memberUuid.toString(), since, REPEATED_WRONG_MIN_WRONG_COUNT);
        if (rows.isEmpty()) {
            return RepeatedWrongStat.EMPTY;
        }
        int unresolvedCount = (int) rows.stream().filter(row -> !Boolean.TRUE.equals(row[1])).count();
        Map<String, Long> countByTopicName = rows.stream()
                .collect(Collectors.groupingBy(row -> (String) row[0], Collectors.counting()));
        // 절반 넘게 몰린 토픽 (2문제 이상일 때만)
        String dominantTopicName = countByTopicName.entrySet().stream()
                .filter(entry -> entry.getValue() * 2 > rows.size() && entry.getValue() >= 2)
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(null);
        return new RepeatedWrongStat(rows.size(), unresolvedCount, dominantTopicName);
    }

    /** 이 회원이 열 수 있는 개념 학습 단원 (이용 불가·잠김 제외, 조회 실패면 바로 가기 없이 분석 유지) */
    private Set<UUID> findOpenConceptTopicUuids(UUID memberUuid) {
        try {
            return conceptLearningService.getTopics(memberUuid).topics().stream()
                    .filter(topic -> !topic.isLocked())
                    .map(ConceptTopicSummary::topicUuid)
                    .collect(Collectors.toSet());
        } catch (RuntimeException e) {
            log.warn("[stats ai analysis] concept topics skipped : member={}, cause={}", memberUuid, e.getClass().getSimpleName(), e);
            return Set.of();
        }
    }

    /** 집중 토픽의 세부 주제 (3문제 이상), 집중 토픽 순서 > 세부 주제 정렬 순서 */
    public List<SubtopicStat> loadSubtopicStats(UUID memberUuid, List<TopicLearningStat> focusTopics) {
        List<String> focusTopicUuids = toUuidStrings(focusTopics);
        LocalDateTime since = LocalDateTime.now().minusDays(ANALYSIS_STATS_RECENT_DAYS);
        return statsAnalysisQueryRepository.findSubtopicStatsAfter(
                        memberUuid.toString(), since, focusTopicUuids, MIN_SUBTOPIC_SOLVED_COUNT).stream()
                // Object[] = { topicUuid, topicName, subtopicName, solvedCount, correctRate }
                .sorted(Comparator.comparingInt(row -> focusTopicUuids.indexOf(row[0].toString())))
                .map(row -> new SubtopicStat((String) row[1], (String) row[2],
                        ((Number) row[3]).intValue(), ((Number) row[4]).doubleValue()))
                .toList();
    }

    /** 집중 토픽에서 마지막 시도가 오답인 문제 최근 8건 */
    public List<WrongQuestionSummary> loadRecentWrongs(UUID memberUuid, List<TopicLearningStat> focusTopics) {
        return statsAnalysisQueryRepository.findRecentLatestWrongQuestions(
                        memberUuid.toString(), toUuidStrings(focusTopics), MAX_RECENT_WRONG_COUNT).stream()
                // Object[] = { topicName, subtopicName(null 가능), stem }
                .map(row -> new WrongQuestionSummary((String) row[0], (String) row[1], (String) row[2]))
                .toList();
    }

    /** 이번 주 [지금-7일, 지금), 지난주 [지금-14일, 지금-7일) 제출 집계 (submitted_at 은 서버 로컬 KST, #560) */
    private TwoWeekSubmissionCounts loadTwoWeekCounts(UUID memberUuid) {
        LocalDateTime now = LocalDateTime.now();
        List<Object[]> rows = statsAnalysisQueryRepository.findTwoWeekSubmissionCounts(
                memberUuid.toString(), now.minusDays(DAYS_PER_WEEK), now.minusDays(DAYS_PER_WEEK * 2L));
        if (rows.isEmpty()) {
            return TwoWeekSubmissionCounts.EMPTY;
        }
        Object[] row = rows.get(0);
        return new TwoWeekSubmissionCounts(toLong(row[0]), toLong(row[1]), toLong(row[2]), toLong(row[3]));
    }

    /** 홈과 같은 다가오는 시험까지 남은 일수 (KST, 지난 시험·일정 없음이면 null) */
    private Integer findDaysUntilExam() {
        return examScheduleService.findEffectiveSchedule()
                .map(schedule -> ChronoUnit.DAYS.between(examScheduleService.getTodayInKorea(), schedule.getExamDate()))
                .filter(days -> days >= 0)
                .map(Long::intValue)
                .orElse(null);
    }

    /** 활성 토픽 전체 (정렬 순서) + 최근 90일 토픽 수치 (풀이 없으면 0문제, 결과 화면 세션 코멘트도 사용) */
    public List<TopicLearningStat> loadTopicStats(UUID memberUuid) {
        UUID subjectOneTopicUuid = topicRepository.findByCode(SUBJECT_ONE_TOPIC_CODE)
                .map(Topic::getTopicUuid)
                .orElse(null);
        LocalDateTime since = LocalDateTime.now().minusDays(ANALYSIS_STATS_RECENT_DAYS);
        // Object[] = { topicUuid, solvedCount, correctRate }
        Map<String, Object[]> statRowByTopicUuid = new HashMap<>();
        for (Object[] row : submissionRepository.findTopicStatsAfter(memberUuid.toString(), since)) {
            statRowByTopicUuid.put(row[0].toString(), row);
        }
        return topicRepository.findByIsActiveTrueOrderBySortOrderAsc().stream()
                .map(topic -> {
                    Object[] row = statRowByTopicUuid.get(topic.getTopicUuid().toString());
                    int solvedCount = row == null ? 0 : ((Number) row[1]).intValue();
                    double correctRate = row == null ? 0.0 : ((Number) row[2]).doubleValue();
                    return new TopicLearningStat(topic.getTopicUuid(), topic.getDisplayName(),
                            Objects.equals(topic.getTopicUuid(), subjectOneTopicUuid), solvedCount, correctRate);
                })
                .toList();
    }

    private static List<String> toUuidStrings(List<TopicLearningStat> topics) {
        return topics.stream().map(topic -> topic.topicUuid().toString()).toList();
    }

    private static long toLong(Object value) {
        return value == null ? 0L : ((Number) value).longValue();
    }
}
