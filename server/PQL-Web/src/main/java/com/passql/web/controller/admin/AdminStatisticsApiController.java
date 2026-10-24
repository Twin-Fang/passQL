package com.passql.web.controller.admin;

import com.passql.application.statistics.AdminAiStatisticsService;
import com.passql.application.statistics.AdminPeriodComparisonService;
import com.passql.application.statistics.AdminStatisticsService;
import com.passql.application.statistics.StatisticsPeriod;
import com.passql.application.statistics.dto.AiMonthlyUsageResponse;
import com.passql.application.statistics.dto.PeriodComparisonResponse;
import com.passql.application.statistics.dto.SignupsByProviderResponse;
import com.passql.web.support.AdminStatisticsCsvExporter;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.Objects;

/** 관리자 AI 사용량·통계 화면 API (#557): AI 월 사용량, 가입 경로별 월 가입 수 */
@RestController
@RequestMapping("/admin/api/statistics")
@RequiredArgsConstructor
public class AdminStatisticsApiController implements AdminStatisticsApiControllerDocs {

    private final AdminStatisticsService adminStatisticsService;
    private final AdminAiStatisticsService adminAiStatisticsService;
    private final AdminPeriodComparisonService adminPeriodComparisonService;

    // 기간 비교 기본 조회 일수 (최근 30일, 직전 30일과 비교)
    private static final int DEFAULT_PERIOD_DAY_COUNT = 30;

    // month 생략 시 이번 달
    @GetMapping("/ai-monthly")
    public ResponseEntity<AiMonthlyUsageResponse> getAiMonthlyUsage(
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM") YearMonth month) {
        return ResponseEntity.ok(adminAiStatisticsService.getAiMonthlyUsage(Objects.requireNonNullElseGet(month, YearMonth::now)));
    }

    @GetMapping("/signups-by-provider")
    public ResponseEntity<SignupsByProviderResponse> getSignupsByProvider() {
        return ResponseEntity.ok(adminStatisticsService.getSignupsByProvider());
    }

    // from·to 생략 시 최근 30일, 직전 기간은 전주·전월 규칙 (StatisticsPeriod)
    @GetMapping("/period-comparison")
    public ResponseEntity<PeriodComparisonResponse> getPeriodComparison(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return ResponseEntity.ok(adminPeriodComparisonService.compare(
                StatisticsPeriod.resolve(from, to, DEFAULT_PERIOD_DAY_COUNT)));
    }

    @GetMapping("/period-comparison.csv")
    public ResponseEntity<byte[]> exportPeriodComparisonCsv(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return AdminStatisticsCsvExporter.periodComparison(adminPeriodComparisonService.compare(
                StatisticsPeriod.resolve(from, to, DEFAULT_PERIOD_DAY_COUNT)));
    }

    @GetMapping("/ai-monthly.csv")
    public ResponseEntity<byte[]> exportAiMonthlyUsageCsv(
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM") YearMonth month) {
        return AdminStatisticsCsvExporter.aiMonthly(
                adminAiStatisticsService.getAiMonthlyUsage(Objects.requireNonNullElseGet(month, YearMonth::now)));
    }
}
