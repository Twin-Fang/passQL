package com.passql.web.controller.admin;

import com.passql.application.constant.StatisticsRange;
import com.passql.application.statistics.AdminAiStatisticsService;
import com.passql.application.statistics.AdminStatisticsService;
import com.passql.application.statistics.dto.DashboardAiStatusResponse;
import com.passql.application.statistics.dto.DashboardAiUsageResponse;
import com.passql.application.statistics.dto.DashboardCommunityResponse;
import com.passql.application.statistics.dto.DashboardGrowthResponse;
import com.passql.application.statistics.dto.DashboardHourlyVisitorResponse;
import com.passql.application.statistics.dto.DashboardLearningResponse;
import com.passql.application.statistics.dto.DashboardRealtimeResponse;
import com.passql.application.statistics.dto.DashboardTopicActivityResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** 관리자 대시보드 그래프·KPI API 8개 (#557): 화면 JS 가 조회, range 기본 DAY */
@RestController
@RequestMapping("/admin/api/dashboard")
@RequiredArgsConstructor
public class AdminDashboardApiController implements AdminDashboardApiControllerDocs {

    private final AdminStatisticsService adminStatisticsService;
    private final AdminAiStatisticsService adminAiStatisticsService;

    @GetMapping("/realtime")
    public ResponseEntity<DashboardRealtimeResponse> getRealtime() {
        return ResponseEntity.ok(adminStatisticsService.getRealtime());
    }

    @GetMapping("/growth")
    public ResponseEntity<DashboardGrowthResponse> getGrowth(
            @RequestParam(defaultValue = "DAY") StatisticsRange range) {
        return ResponseEntity.ok(adminStatisticsService.getGrowth(range));
    }

    @GetMapping("/ai-usage")
    public ResponseEntity<DashboardAiUsageResponse> getAiUsage(
            @RequestParam(defaultValue = "DAY") StatisticsRange range) {
        return ResponseEntity.ok(adminAiStatisticsService.getAiUsage(range));
    }

    @GetMapping("/ai-status")
    public ResponseEntity<DashboardAiStatusResponse> getAiStatus() {
        return ResponseEntity.ok(adminAiStatisticsService.getAiStatus());
    }

    @GetMapping("/learning")
    public ResponseEntity<DashboardLearningResponse> getLearning() {
        return ResponseEntity.ok(adminStatisticsService.getLearning());
    }

    @GetMapping("/community")
    public ResponseEntity<DashboardCommunityResponse> getCommunity() {
        return ResponseEntity.ok(adminStatisticsService.getCommunity());
    }

    @GetMapping("/hourly-visitors")
    public ResponseEntity<DashboardHourlyVisitorResponse> getHourlyVisitors() {
        return ResponseEntity.ok(adminStatisticsService.getHourlyVisitors());
    }

    @GetMapping("/topics")
    public ResponseEntity<List<DashboardTopicActivityResponse>> getTopicActivities() {
        return ResponseEntity.ok(adminStatisticsService.getTopicActivities());
    }
}
