package com.passql.web.controller.admin;

import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.UUID;

/**
 * 관리자 모의고사 화면 (#866): 회차 목록·자동 구성, 회차 상세(문항·공개·문항 통계), 응시 기록 (데이터는 /admin/api/mock-exams)
 */
@Controller
@RequestMapping("/admin/mock-exams")
public class AdminMockExamController {

    @GetMapping
    @AdminPage(menu = AdminMenu.MOCK_EXAMS)
    public String roundsPage() {
        return "admin/mock-exams";
    }

    @GetMapping("/{roundUuid}")
    @AdminPage(menu = AdminMenu.MOCK_EXAMS, title = "모의고사 회차 상세")
    public String roundDetailPage(@PathVariable UUID roundUuid, Model model) {
        model.addAttribute("roundUuid", roundUuid);
        return "admin/mock-exam-detail";
    }

    @GetMapping("/attempts")
    @AdminPage(menu = AdminMenu.MOCK_EXAMS, title = "모의고사 응시 기록")
    public String attemptsPage() {
        return "admin/mock-exam-attempts";
    }
}
