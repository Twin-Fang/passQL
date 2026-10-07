package com.passql.web.controller.admin;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * 태그 관리는 개념 화면(/admin/concepts)에서 한다.
 * 템플릿 없는 admin/tags 뷰를 반환해 500이 나던 옛 진입점을 개념 화면으로 넘긴다 (#392).
 */
@Controller
@RequestMapping("/admin/tags")
public class AdminTagController {

    @GetMapping
    public String list() {
        return "redirect:/admin/concepts";
    }
}
