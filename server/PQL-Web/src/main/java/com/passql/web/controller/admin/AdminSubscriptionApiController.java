package com.passql.web.controller.admin;

import com.passql.application.statistics.AdminSubscriptionService;
import com.passql.application.statistics.StatisticsPeriod;
import com.passql.application.statistics.dto.SubscriptionSummaryResponse;
import com.passql.web.support.AdminStatisticsCsvExporter;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;

/** 관리자 구독·매출 현황 API (#619): 요약 조회, CSV 내보내기 */
@RestController
@RequestMapping("/admin/api/subscriptions")
@RequiredArgsConstructor
public class AdminSubscriptionApiController implements AdminSubscriptionApiControllerDocs {

    // 기본 조회 일수 (최근 30일)
    private static final int DEFAULT_PERIOD_DAY_COUNT = 30;

    private final AdminSubscriptionService adminSubscriptionService;

    @GetMapping("/summary")
    public ResponseEntity<SubscriptionSummaryResponse> getSummary(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return ResponseEntity.ok(adminSubscriptionService.getSummary(StatisticsPeriod.resolve(from, to, DEFAULT_PERIOD_DAY_COUNT)));
    }

    @GetMapping("/summary.csv")
    public ResponseEntity<byte[]> exportSummaryCsv(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return AdminStatisticsCsvExporter.subscription(
                adminSubscriptionService.getSummary(StatisticsPeriod.resolve(from, to, DEFAULT_PERIOD_DAY_COUNT)));
    }
}
