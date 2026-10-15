package com.passql.web.controller.admin;

import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.meta.dto.AdminAuditLogSearchCondition;
import com.passql.meta.service.AdminAuditLogService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import com.passql.web.support.AdminPageRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * 관리자 감사 로그 조회: 관리자·대상 종류·기간 필터 + 최신순 페이지 (#469)
 */
@Controller
@RequestMapping("/admin/audit-logs")
@RequiredArgsConstructor
public class AdminAuditLogController {

    // 감사 로그 정렬 기준 필드 (AdminAuditLog.occurredAt)
    private static final String OCCURRED_AT_FIELD = "occurredAt";

    private final AdminAuditLogService adminAuditLogService;

    @GetMapping
    @AdminPage(menu = AdminMenu.AUDIT_LOGS)
    public String list(AdminAuditLogSearchCondition condition, Model model,
                       @RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = AdminPageRequest.DEFAULT_PAGE_SIZE) int size) {
        model.addAttribute("auditLogs", adminAuditLogService.search(condition,
                AdminPageRequest.newestFirstBy(page, size, OCCURRED_AT_FIELD)));
        model.addAttribute("condition", condition);
        model.addAttribute("targetTypes", AdminAuditTargetType.values());
        return "admin/audit-logs";
    }
}
