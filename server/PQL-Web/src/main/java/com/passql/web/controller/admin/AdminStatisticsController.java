package com.passql.web.controller.admin;

import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/** AI 사용량·통계 화면 (#557): 데이터는 화면 JS 가 /admin/api/statistics/** 로 조회 */
@Controller
@RequestMapping("/admin/statistics")
public class AdminStatisticsController {

    @GetMapping
    @AdminPage(menu = AdminMenu.STATISTICS)
    public String statisticsPage() {
        return "admin/statistics";
    }
}
