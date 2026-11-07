package com.passql.web.controller.admin;

import com.passql.application.questionformat.QuestionFormatAuditService;
import com.passql.common.util.RequestEnumParser;
import com.passql.question.constant.QuestionFormatViolationReason;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * 관리자 문제 형식 검사 화면 (#905): 일괄 점검 결과(사유별 건수·위반 줄·바로 가기) + 자동 정리 미리보기·적용 (데이터는 /admin/api/question-format)
 */
@Controller
@RequestMapping("/admin/question-format")
@RequiredArgsConstructor
public class AdminQuestionFormatController {

    private final QuestionFormatAuditService questionFormatAuditService;

    @GetMapping
    @AdminPage(menu = AdminMenu.QUESTION_FORMAT)
    public String auditPage(@RequestParam(required = false) String reason, Model model) {
        QuestionFormatViolationReason reasonFilter = RequestEnumParser.parseOrNull(QuestionFormatViolationReason.class, reason);
        model.addAttribute("report", questionFormatAuditService.audit(reasonFilter));
        model.addAttribute("selectedReason", reasonFilter);
        return "admin/question-format";
    }
}
