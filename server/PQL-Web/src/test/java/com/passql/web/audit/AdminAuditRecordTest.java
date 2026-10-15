package com.passql.web.audit;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.util.AdminRequestContext;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.member.constant.MemberRole;
import com.passql.meta.entity.AdminAuditLog;
import com.passql.meta.repository.AdminAuditLogRepository;
import com.passql.meta.service.AdminAuditLogService;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.User;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

/** 감사 기록 공통 지점 (#469): 관리자 세션 > 관리자 아이디, 회원 JWT·세션 없음 > system, 변경 요약 JSON */
class AdminAuditRecordTest {

    @AfterEach
    void clearSecurityContext() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void 관리자_세션이면_관리자_아이디와_변경_전후_JSON을_남긴다() {
        signInAsAdmin("operator");
        AdminAuditLogRepository repository = mock(AdminAuditLogRepository.class);
        AdminAuditLogService service = new AdminAuditLogService(repository, new ObjectMapper());

        service.record(AdminAuditEvent.of(AdminAuditTargetType.APP_SETTING, "store.ios_url", AdminAuditAction.UPDATE,
                AdminAuditEvent.summary("value", null), AdminAuditEvent.summary("value", "https://apps.apple.com/x")));

        ArgumentCaptor<AdminAuditLog> saved = ArgumentCaptor.forClass(AdminAuditLog.class);
        verify(repository).save(saved.capture());
        assertThat(saved.getValue().getAdminUsername()).isEqualTo("operator");
        assertThat(saved.getValue().getChangeSummaryJson())
                .isEqualTo("{\"before\":{\"value\":null},\"after\":{\"value\":\"https://apps.apple.com/x\"}}");
    }

    @Test
    void 회원_JWT_요청이나_세션이_없으면_system() {
        assertThat(AdminRequestContext.findAdminUsernameOrSystem()).isEqualTo("system");

        SecurityContextHolder.getContext().setAuthentication(new UsernamePasswordAuthenticationToken(
                new LoginMember(UUID.randomUUID(), MemberRole.values()[0]), null, List.of()));
        assertThat(AdminRequestContext.findAdminUsernameOrSystem()).isEqualTo("system");
    }

    @Test
    void 요약은_긴_문자열을_자르고_null_값을_허용한다() {
        String longBody = "a".repeat(1000);
        var summary = AdminAuditEvent.summary("body", longBody, "hint", null);
        assertThat((String) summary.get("body")).hasSize(301);
        assertThat(summary).containsKey("hint");
    }

    private void signInAsAdmin(String username) {
        var adminUser = User.withUsername(username).password("x").roles("ADMIN").build();
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(adminUser, null, adminUser.getAuthorities()));
    }
}
