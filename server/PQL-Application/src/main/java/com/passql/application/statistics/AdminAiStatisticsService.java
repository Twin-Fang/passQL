package com.passql.application.statistics;

import com.passql.ai.client.GeminiClient;
import com.passql.ai.constant.AiFailureCategory;
import com.passql.ai.dto.GeminiApiKeyHealth;
import com.passql.ai.service.AiCostCalculator;
import com.passql.application.constant.StatisticsRange;
import com.passql.application.dto.CircuitBreakerStatus;
import com.passql.application.dto.SystemHealthSnapshot;
import com.passql.application.service.SystemHealthService;
import com.passql.application.statistics.AdminAiStatisticsQueryRepository.AiCallBucketRow;
import com.passql.application.statistics.AdminAiStatisticsQueryRepository.AiTokenBucketRow;
import com.passql.application.statistics.AdminAiStatisticsQueryRepository.AiUsageGroupRow;
import com.passql.application.statistics.AdminAiStatisticsQueryRepository.ErrorTypeCountRow;
import com.passql.application.statistics.dto.AiModelUsageSummary;
import com.passql.application.statistics.dto.AiMonthlyUsageResponse;
import com.passql.application.statistics.dto.AiMonthlyUsageResponse.EndpointUsage;
import com.passql.application.statistics.dto.DashboardAiStatusResponse;
import com.passql.application.statistics.dto.DashboardAiStatusResponse.AiFailureBreakdown;
import com.passql.application.statistics.dto.DashboardAiStatusResponse.AiServerStatus;
import com.passql.application.statistics.dto.DashboardAiStatusResponse.GeminiKeyStatus;
import com.passql.application.statistics.dto.DashboardAiUsageResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 관리자 AI 통계: 호출량·비용 추이, API 상태(서버·서킷·Gemini 키·실패 원인·이번 달 비용), 월 사용량 표
 * 비용 = 모델별 토큰 합 × 단가표 (AiCostCalculator, 단가 미등록 모델은 0)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminAiStatisticsService {

    // AiGatewayClient.checkAiServerHealth 구성 요소 이름
    static final String AI_SERVER_COMPONENT_NAME = "AI 서버";
    // AiGatewayClient @CircuitBreaker 이름
    static final String AI_SERVER_CIRCUIT_BREAKER_NAME = "aiServer";
    // 서킷 미등록 (AI 서버 호출 전 기동 직후)
    static final String UNKNOWN_CIRCUIT_STATE = "UNKNOWN";
    // 모델 미기록 호출 묶음 이름 (Python 응답 메타 없음·이전 기록)
    static final String UNRECORDED_MODEL_NAME = "미기록";
    // 실패 원인 집계 기간 (시간)
    static final int FAILURE_BREAKDOWN_HOURS = 24;

    private final AdminAiStatisticsQueryRepository aiStatisticsQueryRepository;
    private final AiCostCalculator aiCostCalculator;
    private final SystemHealthService systemHealthService;
    private final GeminiClient geminiClient;

    /** 호출량 추이: 축 생성 > 묶음별 호출 > 묶음별 비용 > 0 채움 */
    public DashboardAiUsageResponse getAiUsage(StatisticsRange range) {
        StatisticsTimeAxis axis = StatisticsTimeAxis.endingAt(range, LocalDate.now());
        Map<LocalDate, AiCallBucketRow> callByBucket = aiStatisticsQueryRepository
                .countCallsByBucket(range, axis.getStartInclusive(), axis.getEndExclusive()).stream()
                .collect(Collectors.toMap(AiCallBucketRow::bucketStartDate, Function.identity()));
        Map<LocalDate, Double> costByBucket = sumCostByBucket(aiStatisticsQueryRepository
                .sumTokensByBucketAndModel(range, axis.getStartInclusive(), axis.getEndExclusive()));
        return new DashboardAiUsageResponse(
                axis.getLabels(),
                axis.fill(callByBucket, AiCallBucketRow::successCount, 0L),
                axis.fill(callByBucket, row -> row.callCount() - row.successCount(), 0L),
                axis.fill(callByBucket,
                        row -> StatisticsNumbers.divideRounded(row.totalLatencyMilliseconds(), row.callCount()), 0L),
                axis.fill(costByBucket, StatisticsNumbers::roundCostUsd, 0.0));
    }

    /**
     * AI API 상태: 구성 요소 확인 > 실패 원인 분류 > 이번 달 모델별 비용 > 예산 사용률
     * 외부 상태 확인(최대 3초) 동안 DB 커넥션을 잡지 않게 트랜잭션 밖에서 실행
     */
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public DashboardAiStatusResponse getAiStatus() {
        SystemHealthSnapshot healthSnapshot = systemHealthService.collect();
        // 위 collect 가 같은 캐시를 채워 추가 호출 없음 (5분 캐시)
        GeminiApiKeyHealth geminiApiKeyHealth = geminiClient.checkApiKeyHealth();
        AiFailureBreakdown failureBreakdown = classifyFailures(aiStatisticsQueryRepository
                .countFailuresByErrorType(LocalDateTime.now().minusHours(FAILURE_BREAKDOWN_HOURS)));

        YearMonth thisMonth = YearMonth.now();
        List<AiModelUsageSummary> costByModel = summarizeByModel(sumUsageOfMonth(thisMonth));
        double monthEstimatedCostUsd = StatisticsNumbers.roundCostUsd(
                costByModel.stream().mapToDouble(AiModelUsageSummary::estimatedCostUsd).sum());
        double monthlyBudgetUsd = aiCostCalculator.getMonthlyBudgetUsd();

        return new DashboardAiStatusResponse(
                toAiServerStatus(healthSnapshot),
                findAiServerCircuitState(healthSnapshot),
                new GeminiKeyStatus(geminiApiKeyHealth.isValid(), geminiApiKeyHealth.checkedAt(), geminiApiKeyHealth.detail()),
                failureBreakdown,
                costByModel.stream().mapToLong(AiModelUsageSummary::promptTokenCount).sum(),
                costByModel.stream().mapToLong(AiModelUsageSummary::completionTokenCount).sum(),
                monthEstimatedCostUsd,
                monthlyBudgetUsd,
                StatisticsNumbers.toPercent(monthEstimatedCostUsd, monthlyBudgetUsd),
                costByModel);
    }

    /** 월 사용량 표: 출처·경로·모델 묶음 조회 > 모델별·경로별 합산 > 합계 + 단가표 */
    public AiMonthlyUsageResponse getAiMonthlyUsage(YearMonth month) {
        List<AiUsageGroupRow> usageGroups = sumUsageOfMonth(month);
        List<AiModelUsageSummary> byModel = summarizeByModel(usageGroups);
        List<EndpointUsage> byEndpoint = summarizeByEndpoint(usageGroups);
        return new AiMonthlyUsageResponse(
                month.toString(),
                byModel.stream().mapToLong(AiModelUsageSummary::callCount).sum(),
                byModel.stream().mapToLong(AiModelUsageSummary::failureCount).sum(),
                byModel.stream().mapToLong(AiModelUsageSummary::promptTokenCount).sum(),
                byModel.stream().mapToLong(AiModelUsageSummary::completionTokenCount).sum(),
                StatisticsNumbers.roundCostUsd(byModel.stream().mapToDouble(AiModelUsageSummary::estimatedCostUsd).sum()),
                aiCostCalculator.getMonthlyBudgetUsd(),
                byModel,
                byEndpoint,
                aiCostCalculator.getPriceTable());
    }

    private List<AiUsageGroupRow> sumUsageOfMonth(YearMonth month) {
        return aiStatisticsQueryRepository.sumUsageBySourceEndpointAndModel(
                month.atDay(1).atStartOfDay(), month.plusMonths(1).atDay(1).atStartOfDay());
    }

    /** 묶음·모델별 토큰 > 묶음별 비용 합 */
    private Map<LocalDate, Double> sumCostByBucket(List<AiTokenBucketRow> tokenRows) {
        return tokenRows.stream().collect(Collectors.groupingBy(AiTokenBucketRow::bucketStartDate,
                Collectors.summingDouble(row -> estimateCostUsd(row.modelName(), row.promptTokenCount(), row.completionTokenCount()))));
    }

    /** error_type 별 건수 > 실패 원인 4종 건수 */
    static AiFailureBreakdown classifyFailures(List<ErrorTypeCountRow> errorTypeCounts) {
        Map<AiFailureCategory, Long> countByCategory = new EnumMap<>(AiFailureCategory.class);
        for (ErrorTypeCountRow row : errorTypeCounts) {
            countByCategory.merge(AiFailureCategory.fromErrorType(row.errorType()), row.count(), Long::sum);
        }
        return new AiFailureBreakdown(
                countByCategory.getOrDefault(AiFailureCategory.QUOTA_EXCEEDED, 0L),
                countByCategory.getOrDefault(AiFailureCategory.PERMISSION_DENIED, 0L),
                countByCategory.getOrDefault(AiFailureCategory.TIMEOUT_OR_SERVER_ERROR, 0L),
                countByCategory.getOrDefault(AiFailureCategory.OTHER, 0L));
    }

    /** 출처·경로·모델 묶음 > 모델별 합 (호출 많은 순) */
    private List<AiModelUsageSummary> summarizeByModel(List<AiUsageGroupRow> usageGroups) {
        Map<String, List<AiUsageGroupRow>> groupsByModel = usageGroups.stream()
                .collect(Collectors.groupingBy(row -> Objects.requireNonNullElse(row.modelName(), UNRECORDED_MODEL_NAME)));
        return groupsByModel.entrySet().stream()
                .map(entry -> toModelUsageSummary(entry.getKey(), entry.getValue()))
                .sorted((left, right) -> Long.compare(right.callCount(), left.callCount()))
                .toList();
    }

    private AiModelUsageSummary toModelUsageSummary(String modelName, List<AiUsageGroupRow> rows) {
        long promptTokenCount = rows.stream().mapToLong(AiUsageGroupRow::promptTokenCount).sum();
        long completionTokenCount = rows.stream().mapToLong(AiUsageGroupRow::completionTokenCount).sum();
        String pricedModelName = UNRECORDED_MODEL_NAME.equals(modelName) ? null : modelName;
        return new AiModelUsageSummary(
                modelName,
                rows.stream().mapToLong(AiUsageGroupRow::callCount).sum(),
                rows.stream().mapToLong(AiUsageGroupRow::failureCount).sum(),
                promptTokenCount,
                completionTokenCount,
                StatisticsNumbers.roundCostUsd(estimateCostUsd(pricedModelName, promptTokenCount, completionTokenCount)),
                pricedModelName != null && aiCostCalculator.isPriceRegistered(pricedModelName));
    }

    /** 출처·경로·모델 묶음 > 출처·경로별 합 (호출 많은 순, 비용은 모델별로 계산 후 합) */
    private List<EndpointUsage> summarizeByEndpoint(List<AiUsageGroupRow> usageGroups) {
        Map<String, List<AiUsageGroupRow>> groupsByEndpoint = usageGroups.stream()
                .collect(Collectors.groupingBy(row -> row.callSource() + " " + row.endpointPath()));
        return groupsByEndpoint.values().stream()
                .map(this::toEndpointUsage)
                .sorted((left, right) -> Long.compare(right.callCount(), left.callCount()))
                .toList();
    }

    private EndpointUsage toEndpointUsage(List<AiUsageGroupRow> rows) {
        AiUsageGroupRow firstRow = rows.getFirst();
        long callCount = rows.stream().mapToLong(AiUsageGroupRow::callCount).sum();
        double estimatedCostUsd = rows.stream()
                .mapToDouble(row -> estimateCostUsd(row.modelName(), row.promptTokenCount(), row.completionTokenCount()))
                .sum();
        return new EndpointUsage(
                firstRow.callSource(),
                firstRow.endpointPath(),
                callCount,
                rows.stream().mapToLong(AiUsageGroupRow::failureCount).sum(),
                StatisticsNumbers.divideRounded(rows.stream().mapToLong(AiUsageGroupRow::totalLatencyMilliseconds).sum(), callCount),
                rows.stream().mapToLong(AiUsageGroupRow::promptTokenCount).sum(),
                rows.stream().mapToLong(AiUsageGroupRow::completionTokenCount).sum(),
                StatisticsNumbers.roundCostUsd(estimatedCostUsd));
    }

    /** 모델 미기록·단가 미등록이면 0 */
    private double estimateCostUsd(String modelName, long promptTokenCount, long completionTokenCount) {
        if (modelName == null) {
            return 0;
        }
        return aiCostCalculator.estimateCostUsd(modelName, promptTokenCount, completionTokenCount);
    }

    /** 상태 묶음 > AI 서버 결과 (없으면 down) */
    private static AiServerStatus toAiServerStatus(SystemHealthSnapshot healthSnapshot) {
        return healthSnapshot.components().stream()
                .filter(component -> AI_SERVER_COMPONENT_NAME.equals(component.componentName()))
                .findFirst()
                .map(component -> new AiServerStatus(component.isUp(), component.latencyMilliseconds(), component.detail()))
                .orElseGet(() -> new AiServerStatus(false, 0, "상태 확인 결과 없음"));
    }

    private static String findAiServerCircuitState(SystemHealthSnapshot healthSnapshot) {
        return healthSnapshot.circuitBreakers().stream()
                .filter(circuitBreaker -> AI_SERVER_CIRCUIT_BREAKER_NAME.equals(circuitBreaker.circuitBreakerName()))
                .map(CircuitBreakerStatus::state)
                .findFirst()
                .orElse(UNKNOWN_CIRCUIT_STATE);
    }
}
