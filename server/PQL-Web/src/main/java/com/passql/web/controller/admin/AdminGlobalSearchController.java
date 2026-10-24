package com.passql.web.controller.admin;

import com.passql.application.service.AdminGlobalSearchService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * 관리자 전역 검색: 회원·문제 UUID, 회원 닉네임 > 결과 1건이면 바로 상세, 여러 건이면 목록 (조회 전용, 관리자·뷰어 모두)
 */
@Controller
@RequestMapping("/admin/search")
@RequiredArgsConstructor
public class AdminGlobalSearchController {

    private final AdminGlobalSearchService adminGlobalSearchService;

    @GetMapping
    @AdminPage(menu = AdminMenu.GLOBAL_SEARCH)
    public String search(@RequestParam(name = "q", defaultValue = "") String keyword, Model model) {
        AdminGlobalSearchService.Result result = adminGlobalSearchService.search(keyword);
        // 결과 1건이면 상세로 바로 이동
        if (result.findSingleHitPath().isPresent()) {
            return "redirect:" + result.findSingleHitPath().get();
        }
        model.addAttribute("searchResult", result);
        return "admin/search-results";
    }
}
