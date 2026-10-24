package com.passql.web.controller.admin;

import com.passql.application.statistics.AdminRetentionService;
import com.passql.application.statistics.StatisticsPeriod;
import com.passql.application.statistics.dto.RetentionResponse;
import com.passql.web.support.AdminStatisticsCsvExporter;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;

/** 관리자 리텐션·코호트 API (#620): 조회, CSV 내보내기 */
@RestController
@RequestMapping("/admin/api/retention")
@RequiredArgsConstructor
public class AdminRetentionApiController implements AdminRetentionApiControllerDocs {

    // 기본 가입 기간 (최근 56일 = 8주, 주차 코호트 8행)
    private static final int DEFAULT_PERIOD_DAY_COUNT = 56;

    private final AdminRetentionService adminRetentionService;

    @GetMapping
    public ResponseEntity<RetentionResponse> getRetention(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return ResponseEntity.ok(adminRetentionService.getRetention(StatisticsPeriod.resolve(from, to, DEFAULT_PERIOD_DAY_COUNT)));
    }

    @GetMapping("/export.csv")
    public ResponseEntity<byte[]> exportRetentionCsv(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return AdminStatisticsCsvExporter.retention(
                adminRetentionService.getRetention(StatisticsPeriod.resolve(from, to, DEFAULT_PERIOD_DAY_COUNT)));
    }
}
