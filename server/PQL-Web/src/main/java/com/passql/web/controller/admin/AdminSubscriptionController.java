package com.passql.web.controller.admin;

import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/** 구독·매출 현황 화면 (#619): 데이터는 화면 JS 가 /admin/api/subscriptions/** 로 조회 */
@Controller
@RequestMapping("/admin/subscriptions")
public class AdminSubscriptionController {

    @GetMapping
    @AdminPage(menu = AdminMenu.SUBSCRIPTIONS)
    public String subscriptionsPage() {
        return "admin/subscriptions";
    }
}
