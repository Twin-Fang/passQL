package com.passql.web.controller.admin;

import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.UUID;

@Controller
@RequestMapping("/admin/reports")
public class AdminReportViewController {

    @GetMapping
    @AdminPage(menu = AdminMenu.REPORTS)
    public String reportsPage(Model model) {
        return "admin/reports";
    }

    @GetMapping("/{questionUuid}")
    @AdminPage(menu = AdminMenu.REPORTS, title = "신고 상세")
    public String reportDetailPage(@PathVariable UUID questionUuid, Model model) {
        model.addAttribute("questionUuid", questionUuid);
        return "admin/report-detail";
    }
}
