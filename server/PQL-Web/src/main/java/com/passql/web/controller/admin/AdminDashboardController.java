package com.passql.web.controller.admin;

import com.passql.application.dto.DashboardStats;
import com.passql.application.service.AdminDashboardService;
import com.passql.meta.service.ExamScheduleCoverageService;
import com.passql.submission.service.SubmissionService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * 관리자 대시보드 컨트롤러.
 *
 * <p>{@code /admin} 진입점으로, AdminDashboardService를 통해 통계를 수집해
 * dashboard.html 템플릿에 바인딩한다.
 */
@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminDashboardController {

    private final AdminDashboardService adminDashboardService;
    private final SubmissionService submissionService;
    private final ExamScheduleCoverageService examCoverageService;

    @GetMapping({"", "/"})
    @AdminPage(menu = AdminMenu.DASHBOARD)
    public String dashboard(Model model) {
        DashboardStats stats = adminDashboardService.collect();

        model.addAttribute("stats", stats);
        model.addAttribute("recentLogs", submissionService.getRecentLogs());
        // 시험 일정 공고 확인이 필요하면 대시보드 상단에 알린다 (#411)
        model.addAttribute("examAlerts", examCoverageService.getAlerts());
        return "admin/dashboard";
    }
}
