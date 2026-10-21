package com.passql.web.controller.admin;

import com.passql.application.statistics.AdminAiStatisticsService;
import com.passql.application.statistics.AdminStatisticsService;
import com.passql.application.statistics.dto.AiMonthlyUsageResponse;
import com.passql.application.statistics.dto.SignupsByProviderResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.YearMonth;
import java.util.Objects;

/** 관리자 AI 사용량·통계 화면 API (#557): AI 월 사용량, 가입 경로별 월 가입 수 */
@RestController
@RequestMapping("/admin/api/statistics")
@RequiredArgsConstructor
public class AdminStatisticsApiController implements AdminStatisticsApiControllerDocs {

    private final AdminStatisticsService adminStatisticsService;
    private final AdminAiStatisticsService adminAiStatisticsService;

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
}
