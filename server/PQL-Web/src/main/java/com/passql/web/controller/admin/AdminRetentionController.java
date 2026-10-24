package com.passql.web.controller.admin;

import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/** 리텐션·코호트 화면 (#620): 데이터는 화면 JS 가 /admin/api/retention/** 로 조회 */
@Controller
@RequestMapping("/admin/retention")
public class AdminRetentionController {

    @GetMapping
    @AdminPage(menu = AdminMenu.RETENTION)
    public String retentionPage() {
        return "admin/retention";
    }
}
