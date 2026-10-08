package com.passql.web.controller.admin;

import com.passql.ai.client.GeminiClient;
import com.passql.ai.dto.AiStats;
import com.passql.meta.service.ServerErrorLogService;
import com.passql.submission.service.SubmissionService;
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
    private final GeminiClient geminiClient;
    private final ServerErrorLogService serverErrorLogService;

    @GetMapping
    public String dashboard(Model model) {
        model.addAttribute("executionLogs", submissionService.getRecentLogs());
        model.addAttribute("monitorStats", submissionService.getStats24h());
        // Gemini 호출 수는 인메모리 누적값(배포마다 0) — 화면에 그 사실을 함께 안내한다
        model.addAttribute("aiStats", new AiStats(geminiClient.getCallCount()));
        // 5xx·미처리 예외 기록 (#440)
        model.addAttribute("serverErrors", serverErrorLogService.findRecent());
        model.addAttribute("serverErrorCount24h", serverErrorLogService.countLast24h());
        model.addAttribute("currentMenu", "monitor");
        model.addAttribute("pageTitle", "모니터링");
        return "admin/monitor";
    }
}
