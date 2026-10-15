package com.passql.web.controller.admin;

import com.passql.ai.service.AiCallLogService;
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

@Controller
@RequestMapping("/admin/monitor")
@RequiredArgsConstructor
public class AdminMonitorController {

    private final SubmissionService submissionService;
    private final AiCallLogService aiCallLogService;
    private final SystemHealthService systemHealthService;
    private final ServerErrorLogService serverErrorLogService;

    @GetMapping
    @AdminPage(menu = AdminMenu.MONITOR)
    public String dashboard(Model model) {
        model.addAttribute("executionLogs", submissionService.getRecentLogs());
        model.addAttribute("monitorStats", submissionService.getStats24h());
        // AI 서버 호출 24시간 집계 (ai_call_log, 배포해도 유지, #474)
        model.addAttribute("aiStats", aiCallLogService.getStatsLast24Hours());
        // 5xx·미처리 예외 기록 (#440)
        // AI 서버·Qdrant·Redis 상태, 서킷 상태 (#475)
        model.addAttribute("systemHealth", systemHealthService.collect());
        model.addAttribute("serverErrors", serverErrorLogService.findRecent());
        model.addAttribute("serverErrorCount24h", serverErrorLogService.countLast24h());
        return "admin/monitor";
    }
}
