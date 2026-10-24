package com.passql.web.support;

import com.passql.application.statistics.dto.AiMonthlyUsageResponse;
import com.passql.application.statistics.dto.DashboardAiUsageResponse;
import com.passql.application.statistics.dto.DashboardGrowthResponse;
import com.passql.application.statistics.dto.PeriodComparisonResponse;
import com.passql.application.statistics.dto.RetentionResponse;
import com.passql.application.statistics.dto.SubscriptionSummaryResponse;
import org.springframework.http.ResponseEntity;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

/**
 * 관리자 통계 응답 > CSV 변환 (화면 표와 같은 열 구성): 기간 비교, AI 월 사용량, 대시보드 추이, 구독, 리텐션
 * 파일 응답은 AdminCsvResponseWriter 공통
 */
public final class AdminStatisticsCsvExporter {

    private AdminStatisticsCsvExporter() {
    }

    /** 기간 비교: 지표, 단위, 조회 기간 값, 직전 기간 값, 증감률(%) */
    public static ResponseEntity<byte[]> periodComparison(PeriodComparisonResponse comparison) {
        List<List<?>> rows = comparison.metrics().stream()
                .<List<?>>map(metric -> List.of(metric.metricLabel(), metric.unit(), metric.currentValue(), metric.previousValue(),
                        metric.changePercent() == null ? "" : metric.changePercent()))
                .collect(Collectors.toList());
        return AdminCsvResponseWriter.toResponse(
                "period-comparison_" + comparison.fromDate() + "_" + comparison.toDate() + ".csv",
                List.of("지표", "단위", comparison.fromDate() + "~" + comparison.toDate(),
                        comparison.previousFromDate() + "~" + comparison.previousToDate(), "증감률(%)"),
                rows);
    }

    /** AI 월 사용량: 모델별 행 + 기능별 행 (구분 열로 구별) */
    public static ResponseEntity<byte[]> aiMonthly(AiMonthlyUsageResponse aiMonthly) {
        List<List<?>> rows = new ArrayList<>();
        aiMonthly.byModel().forEach(model -> rows.add(Arrays.asList(
                "모델", model.modelName(), "", model.callCount(), model.failureCount(), "",
                model.promptTokenCount(), model.completionTokenCount(), model.estimatedCostUsd())));
        aiMonthly.byEndpoint().forEach(endpoint -> rows.add(Arrays.asList(
                "기능", endpoint.endpointPath(), endpoint.callSource(), endpoint.callCount(), endpoint.failureCount(),
                endpoint.averageLatencyMilliseconds(), endpoint.promptTokenCount(), endpoint.completionTokenCount(),
                endpoint.estimatedCostUsd())));
        return AdminCsvResponseWriter.toResponse("ai-usage_" + aiMonthly.month() + ".csv",
                List.of("구분", "이름", "호출 경로", "호출", "실패", "평균 지연(ms)", "입력 토큰", "출력 토큰", "추정 비용(USD)"),
                rows);
    }

    /** 가입·방문자 추이: 라벨별 신규 가입, 방문자, 누적 회원 */
    public static ResponseEntity<byte[]> growth(DashboardGrowthResponse growth, String rangeName) {
        List<List<?>> rows = IntStream.range(0, growth.labels().size())
                .<List<?>>mapToObj(index -> List.of(growth.labels().get(index), growth.signupCounts().get(index),
                        growth.visitorCounts().get(index), growth.cumulativeMemberCounts().get(index)))
                .collect(Collectors.toList());
        return AdminCsvResponseWriter.toResponse("growth_" + rangeName.toLowerCase() + ".csv",
                List.of("기간", "신규 가입", "방문자", "누적 회원"), rows);
    }

    /** AI 호출량 추이: 라벨별 성공, 실패, 평균 지연, 추정 비용 */
    public static ResponseEntity<byte[]> aiUsageTrend(DashboardAiUsageResponse aiUsage, String rangeName) {
        List<List<?>> rows = IntStream.range(0, aiUsage.labels().size())
                .<List<?>>mapToObj(index -> List.of(aiUsage.labels().get(index), aiUsage.successCounts().get(index),
                        aiUsage.failureCounts().get(index), aiUsage.averageLatencyMilliseconds().get(index),
                        aiUsage.estimatedCostUsd().get(index)))
                .collect(Collectors.toList());
        return AdminCsvResponseWriter.toResponse("ai-usage-trend_" + rangeName.toLowerCase() + ".csv",
                List.of("기간", "성공", "실패", "평균 지연(ms)", "추정 비용(USD)"), rows);
    }

    /** 구독 현황: 요약 지표 + 상품별 판매 + 통화별 금액 (구분 열) */
    public static ResponseEntity<byte[]> subscription(SubscriptionSummaryResponse summary) {
        List<List<?>> rows = new ArrayList<>();
        rows.add(List.of("요약", "유효 프로 회원", summary.activeProMemberCount()));
        rows.add(List.of("요약", summary.expiringSoonDayCount() + "일 내 만료 임박", summary.expiringSoonMemberCount()));
        rows.add(List.of("요약", "구간 구매", summary.purchaseCount()));
        rows.add(List.of("요약", "직전 기간 구매", summary.previousPurchaseCount()));
        rows.add(List.of("요약", "구간 회수·환불", summary.revokedPurchaseCount()));
        rows.add(List.of("요약", "직전 기간 회수·환불", summary.previousRevokedPurchaseCount()));
        rows.add(List.of("요약", "구간 가입자 전환율(%)", summary.signupConversionRatePercent()));
        rows.add(List.of("요약", "전체 회원 구매 비율(%)", summary.purchasedMemberRatePercent()));
        summary.productSales().forEach(product -> rows.add(List.of(
                "상품", product.productId() + " (" + product.store() + ")", product.soldCount() + " / 회수 " + product.revokedCount())));
        summary.amounts().forEach(amount -> rows.add(List.of(
                "금액", amount.currencyCode(), amount.amount() + " (" + amount.purchaseCount() + "건)")));
        return AdminCsvResponseWriter.toResponse(
                "subscription_" + summary.fromDate() + "_" + summary.toDate() + ".csv",
                List.of("구분", "항목", "값"), rows);
    }

    /** 리텐션: N일 리텐션 + 주차 코호트 + 기능 이용률 (구분 열) */
    public static ResponseEntity<byte[]> retention(RetentionResponse retention) {
        List<List<?>> rows = new ArrayList<>();
        retention.dayRetentions().forEach(day -> rows.add(List.of(
                "N일 리텐션", "D" + day.dayOffset(), day.eligibleCount(), day.retainedCount(), day.ratePercent())));
        retention.weekCohorts().forEach(cohort -> {
            for (int weekOffset = 0; weekOffset < cohort.retainedCounts().size(); weekOffset++) {
                if (cohort.retainedCounts().get(weekOffset) != null) {
                    rows.add(List.of("주차 코호트", cohort.weekStartDate() + " +" + weekOffset + "주", cohort.cohortSize(),
                            cohort.retainedCounts().get(weekOffset), cohort.retentionRatePercents().get(weekOffset)));
                }
            }
        });
        retention.featureUsages().forEach(feature -> rows.add(List.of(
                "기능 이용률", feature.featureLabel(), retention.activeMemberCount(), feature.userCount(), feature.ratePercent())));
        return AdminCsvResponseWriter.toResponse(
                "retention_" + retention.fromDate() + "_" + retention.toDate() + ".csv",
                List.of("구분", "항목", "대상 회원", "유지·이용 회원", "비율(%)"), rows);
    }
}
