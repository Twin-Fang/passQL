package com.passql.web.controller.admin;

import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/** 커뮤니티 신고 관리 화면 (#525) */
@Controller
@RequestMapping("/admin/community/reports")
public class AdminCommunityReportViewController {

    @GetMapping
    @AdminPage(menu = AdminMenu.COMMUNITY_REPORTS)
    public String communityReportsPage() {
        return "admin/community-reports";
    }
}
