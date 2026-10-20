package com.passql.application.statistics;

import com.passql.application.community.CommunityAdminService;
import com.passql.application.constant.StatisticsRange;
import com.passql.application.dto.DashboardStats;
import com.passql.application.service.AdminDashboardService;
import com.passql.application.statistics.AdminAiStatisticsQueryRepository.AiCallBucketRow;
import com.passql.application.statistics.AdminStatisticsQueryRepository.BucketCountRow;
import com.passql.application.statistics.AdminStatisticsQueryRepository.HourCountRow;
import com.passql.application.statistics.AdminStatisticsQueryRepository.ProviderSignupRow;
import com.passql.application.statistics.AdminStatisticsQueryRepository.SignupBucketRow;
import com.passql.application.statistics.AdminStatisticsQueryRepository.SubmissionBucketRow;
import com.passql.application.statistics.AdminStatisticsQueryRepository.TopicCountRow;
import com.passql.application.statistics.dto.DashboardCommunityResponse;
import com.passql.application.statistics.dto.DashboardGrowthResponse;
import com.passql.application.statistics.dto.DashboardHourlyVisitorResponse;
import com.passql.application.statistics.dto.DashboardLearningResponse;
import com.passql.application.statistics.dto.DashboardRealtimeResponse;
import com.passql.application.statistics.dto.DashboardTopicActivityResponse;
import com.passql.application.statistics.dto.SignupsByProviderResponse;
import com.passql.application.statistics.dto.SignupsByProviderResponse.ProviderSignupSeries;
import com.passql.member.service.MemberActivityRecorder;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

/**
 * 관리자 대시보드 통계: 지금·오늘 KPI, 가입·방문 추이, 학습, 토론, 시간대별 접속, 토픽별 풀이, 가입 경로별 가입
 * 날짜 축은 서버 로컬 오늘 기준, 빈 묶음 0 채움 (AI 사용량·비용은 AdminAiStatisticsService)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminStatisticsService {

    // 학습 그래프 일 수
    static final int LEARNING_DAY_COUNT = 30;
    // 토론 그래프 일 수
    static final int COMMUNITY_DAY_COUNT = 14;
    // 토론 최근 글 건수
    static final int RECENT_POST_LIMIT = 5;
    // 시간대별 접속 평균 기간 (일, 오늘 제외 최근 7일)
    static final int HOURLY_VISITOR_DAY_COUNT = 7;
    // 7일 평균 가입 기간 (일, 오늘 제외)
    static final int SIGNUP_AVERAGE_DAY_COUNT = 7;
    // 토픽별 풀이 수 기간 (일)
    static final int TOPIC_SUBMISSION_DAY_COUNT = 30;
    // 하루 시간대 수
    private static final int HOURS_PER_DAY = 24;

    private final AdminStatisticsQueryRepository statisticsQueryRepository;
    private final AdminAiStatisticsQueryRepository aiStatisticsQueryRepository;
    private final MemberActivityRecorder memberActivityRecorder;
    private final CommunityAdminService communityAdminService;
    private final AdminDashboardService adminDashboardService;

    /** 지금·오늘 KPI: 온라인 > 방문 > 가입 > 제출 > AI 호출 > 토론 */
    public DashboardRealtimeResponse getRealtime() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime todayStart = now.toLocalDate().atStartOfDay();
        LocalDateTime yesterdayStart = todayStart.minusDays(1);

        SubmissionTotal todaySubmission = sumSubmissions(todayStart, now);
        AiCallTotal todayAiCall = sumAiCalls(todayStart, now);
        long todayCommunityPostCount = statisticsQueryRepository.countCommunityPostsByDay(todayStart, now).stream()
                .mapToLong(BucketCountRow::count).sum();

        return new DashboardRealtimeResponse(
                memberActivityRecorder.countOnlineMembers(),
                statisticsQueryRepository.countVisitors(todayStart, now),
                statisticsQueryRepository.countVisitors(yesterdayStart, now.minusDays(1)),
                statisticsQueryRepository.countSignups(todayStart, now),
                statisticsQueryRepository.countSignups(yesterdayStart, todayStart),
                calculateSevenDayAverageSignupCount(todayStart),
                todaySubmission.submissionCount(),
                StatisticsNumbers.toPercent(todaySubmission.correctCount(), todaySubmission.submissionCount()),
                todayAiCall.callCount(),
                todayAiCall.callCount() - todayAiCall.successCount(),
                StatisticsNumbers.divideRounded(todayAiCall.totalLatencyMilliseconds(), todayAiCall.callCount()),
                todayCommunityPostCount,
                communityAdminService.countPendingPosts(),
                now);
    }

    /** 가입·방문자 추이: 축 생성 > 가입·방문 조회 > 0 채움 > 누적 회원 수 */
    public DashboardGrowthResponse getGrowth(StatisticsRange range) {
        StatisticsTimeAxis axis = StatisticsTimeAxis.endingAt(range, LocalDate.now());
        Map<LocalDate, SignupBucketRow> signupByBucket = statisticsQueryRepository
                .countSignupsByBucket(range, axis.getStartInclusive(), axis.getEndExclusive()).stream()
                .collect(Collectors.toMap(SignupBucketRow::bucketStartDate, row -> row));
        Map<LocalDate, Long> visitorCountByBucket = toCountByBucket(statisticsQueryRepository
                .countVisitorsByBucket(range, axis.getStartInclusive(), axis.getEndExclusive()));

        List<Long> remainingMemberCounts = axis.fill(signupByBucket, SignupBucketRow::remainingMemberCount, 0L);
        long remainingMemberCountBeforeAxis = statisticsQueryRepository
                .countRemainingMembersCreatedBefore(axis.getStartInclusive());
        return new DashboardGrowthResponse(
                axis.getLabels(),
                axis.fill(signupByBucket, SignupBucketRow::signupCount, 0L),
                axis.fill(visitorCountByBucket, 0L),
                StatisticsNumbers.toRunningTotals(remainingMemberCountBeforeAxis, remainingMemberCounts));
    }

    /** 학습 활동 30일: 일별 제출 수·정답률 */
    public DashboardLearningResponse getLearning() {
        StatisticsTimeAxis axis = StatisticsTimeAxis.endingAt(StatisticsRange.DAY, LEARNING_DAY_COUNT, LocalDate.now());
        Map<LocalDate, SubmissionBucketRow> submissionByDay = statisticsQueryRepository
                .countSubmissionsByDay(axis.getStartInclusive(), axis.getEndExclusive()).stream()
                .collect(Collectors.toMap(SubmissionBucketRow::bucketStartDate, row -> row));
        return new DashboardLearningResponse(
                axis.getLabels(),
                axis.fill(submissionByDay, SubmissionBucketRow::submissionCount, 0L),
                axis.fill(submissionByDay,
                        row -> StatisticsNumbers.toPercent(row.correctCount(), row.submissionCount()), 0.0));
    }

    /** 토론 활동 14일: 일별 새 글 수 + 최근 글 5건 */
    public DashboardCommunityResponse getCommunity() {
        StatisticsTimeAxis axis = StatisticsTimeAxis.endingAt(StatisticsRange.DAY, COMMUNITY_DAY_COUNT, LocalDate.now());
        Map<LocalDate, Long> postCountByDay = toCountByBucket(statisticsQueryRepository
                .countCommunityPostsByDay(axis.getStartInclusive(), axis.getEndExclusive()));
        return new DashboardCommunityResponse(
                axis.getLabels(),
                axis.fill(postCountByDay, 0L),
                statisticsQueryRepository.findRecentCommunityPosts(RECENT_POST_LIMIT));
    }

    /** 시간대별 접속: 오늘 제외 최근 7일 시간대별 방문 회원 수 합 / 7 */
    public DashboardHourlyVisitorResponse getHourlyVisitors() {
        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        Map<Integer, Long> visitorCountByHour = statisticsQueryRepository
                .countVisitorsByHourOfDay(todayStart.minusDays(HOURLY_VISITOR_DAY_COUNT), todayStart).stream()
                .collect(Collectors.toMap(HourCountRow::hourOfDay, HourCountRow::count));
        List<Double> averageVisitorCounts = IntStream.range(0, HOURS_PER_DAY)
                .mapToObj(hour -> StatisticsNumbers.roundToOneDecimal(
                        visitorCountByHour.getOrDefault(hour, 0L) / (double) HOURLY_VISITOR_DAY_COUNT))
                .toList();
        return new DashboardHourlyVisitorResponse(averageVisitorCounts);
    }

    /** 토픽별: 활성 문제 수(대시보드 토픽 집계 재사용) + 최근 30일 풀이 수 */
    public List<DashboardTopicActivityResponse> getTopicActivities() {
        Map<UUID, Long> submissionCountByTopic = statisticsQueryRepository
                .countSubmissionsByTopic(LocalDate.now().atStartOfDay().minusDays(TOPIC_SUBMISSION_DAY_COUNT)).stream()
                .collect(Collectors.toMap(TopicCountRow::topicUuid, TopicCountRow::count));
        return adminDashboardService.buildTopicCounts().stream()
                .map(topic -> toTopicActivity(topic, submissionCountByTopic))
                .toList();
    }

    /** 최근 12개월 가입 경로별 월 가입 수 (가입 있었던 경로만, 경로 이름순) */
    public SignupsByProviderResponse getSignupsByProvider() {
        StatisticsTimeAxis axis = StatisticsTimeAxis.endingAt(StatisticsRange.MONTH, LocalDate.now());
        Map<String, Map<LocalDate, Long>> countByMonthByProvider = new LinkedHashMap<>();
        for (ProviderSignupRow row : statisticsQueryRepository
                .countMonthlySignupsByProvider(axis.getStartInclusive(), axis.getEndExclusive())) {
            countByMonthByProvider.computeIfAbsent(row.authProvider(), provider -> new LinkedHashMap<>())
                    .put(row.monthStartDate(), row.count());
        }
        List<ProviderSignupSeries> series = new ArrayList<>();
        countByMonthByProvider.forEach((authProvider, countByMonth) ->
                series.add(new ProviderSignupSeries(authProvider, axis.fill(countByMonth, 0L))));
        return new SignupsByProviderResponse(axis.getLabels(), series);
    }

    /** 어제까지 7일 가입 수 / 7 (소수 1자리) */
    private double calculateSevenDayAverageSignupCount(LocalDateTime todayStart) {
        long signupCount = statisticsQueryRepository.countSignups(
                todayStart.minusDays(SIGNUP_AVERAGE_DAY_COUNT), todayStart);
        return StatisticsNumbers.roundToOneDecimal(signupCount / (double) SIGNUP_AVERAGE_DAY_COUNT);
    }

    private SubmissionTotal sumSubmissions(LocalDateTime start, LocalDateTime end) {
        List<SubmissionBucketRow> rows = statisticsQueryRepository.countSubmissionsByDay(start, end);
        return new SubmissionTotal(
                rows.stream().mapToLong(SubmissionBucketRow::submissionCount).sum(),
                rows.stream().mapToLong(SubmissionBucketRow::correctCount).sum());
    }

    private AiCallTotal sumAiCalls(LocalDateTime start, LocalDateTime end) {
        List<AiCallBucketRow> rows = aiStatisticsQueryRepository.countCallsByBucket(StatisticsRange.DAY, start, end);
        return new AiCallTotal(
                rows.stream().mapToLong(AiCallBucketRow::callCount).sum(),
                rows.stream().mapToLong(AiCallBucketRow::successCount).sum(),
                rows.stream().mapToLong(AiCallBucketRow::totalLatencyMilliseconds).sum());
    }

    private static DashboardTopicActivityResponse toTopicActivity(DashboardStats.TopicQuestionCount topic,
                                                                 Map<UUID, Long> submissionCountByTopic) {
        long submissionCount = submissionCountByTopic.getOrDefault(UUID.fromString(topic.topicUuid()), 0L);
        return new DashboardTopicActivityResponse(topic.topicName(), topic.count(), submissionCount);
    }

    private static Map<LocalDate, Long> toCountByBucket(List<BucketCountRow> rows) {
        return rows.stream().collect(Collectors.toMap(BucketCountRow::bucketStartDate, BucketCountRow::count));
    }

    /** 구간 제출 합계 */
    private record SubmissionTotal(long submissionCount, long correctCount) {}

    /** 구간 AI 호출 합계 */
    private record AiCallTotal(long callCount, long successCount, long totalLatencyMilliseconds) {}
}
