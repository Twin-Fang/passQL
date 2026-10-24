package com.passql.web.controller.admin;

import com.passql.ai.service.AiCallLogService;
import com.passql.application.monitor.MonitorFilter;
import com.passql.application.service.SystemHealthService;
import com.passql.meta.service.ServerErrorLogService;
import com.passql.submission.service.SubmissionService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDateTime;

@Controller
@RequestMapping("/admin/monitor")
@RequiredArgsConstructor
public class AdminMonitorController {

    private final SubmissionService submissionService;
    private final AiCallLogService aiCallLogService;
    private final SystemHealthService systemHealthService;
    private final ServerErrorLogService serverErrorLogService;

    /** 필터(기간·SQL 실행 상태·서버 오류 URI)로 카드·표 조회, 시계열 차트는 화면 JS 가 /admin/api/monitor/timeseries 로 조회 (#622) */
    @GetMapping
    @AdminPage(menu = AdminMenu.MONITOR)
    public String dashboard(Model model,
                            @RequestParam(required = false) Integer hours,
                            @RequestParam(required = false) String status,
                            @RequestParam(required = false) String uri) {
        MonitorFilter filter = MonitorFilter.of(hours, status, uri);
        LocalDateTime since = filter.getSince();

        model.addAttribute("filter", filter);
        model.addAttribute("selectableHours", MonitorFilter.SELECTABLE_HOURS);
        model.addAttribute("selectableExecutionStatuses", MonitorFilter.SELECTABLE_EXECUTION_STATUSES);
        model.addAttribute("executionLogs", submissionService.getRecentLogs(since, filter.executionStatus()));
        model.addAttribute("monitorStats", submissionService.getStatsSince(since));
        // AI 서버 호출 집계 (ai_call_log, 배포해도 유지, #474)
        model.addAttribute("aiStats", aiCallLogService.getStatsSince(since));
        // 5xx·미처리 예외 기록 (#440)
        // AI 서버·Qdrant·Redis 상태, 서킷 상태 (#475)
        model.addAttribute("systemHealth", systemHealthService.collect());
        model.addAttribute("serverErrors", serverErrorLogService.findRecent(since, filter.uriKeyword()));
        model.addAttribute("serverErrorCount", serverErrorLogService.countSince(since));
        return "admin/monitor";
    }
}
