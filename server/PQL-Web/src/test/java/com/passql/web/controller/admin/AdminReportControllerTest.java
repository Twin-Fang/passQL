package com.passql.web.controller.admin;

import com.passql.application.service.QuestionReportService;
import com.passql.question.constant.CorrectionScope;
import com.passql.web.dto.report.ResolveRequest;
import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;

import java.util.List;
import java.util.UUID;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

/** 신고 처리자 (#472): 클라이언트 헤더가 아니라 로그인한 관리자 아이디로 저장 */
class AdminReportControllerTest {

    private final QuestionReportService questionReportService = mock(QuestionReportService.class);
    private final AdminReportController adminReportController = new AdminReportController(questionReportService);

    @Test
    void 처리자는_관리자_인증_주체의_아이디() {
        UUID reportUuid = UUID.randomUUID();
        UsernamePasswordAuthenticationToken adminPrincipal =
                new UsernamePasswordAuthenticationToken("passql-admin", null, List.of());

        adminReportController.resolveReport(reportUuid, adminPrincipal,
                new ResolveRequest(CorrectionScope.NONE, false));

        verify(questionReportService).resolveReport(reportUuid, "passql-admin", CorrectionScope.NONE, false);
    }
}
