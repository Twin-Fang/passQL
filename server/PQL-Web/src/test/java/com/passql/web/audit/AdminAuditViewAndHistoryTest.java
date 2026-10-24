package com.passql.web.audit;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.meta.entity.AdminAuditLog;
import com.passql.meta.repository.AdminAuditLogRepository;
import com.passql.meta.service.AdminAuditLogService;
import com.passql.meta.service.AppSettingHistoryService;
import com.passql.meta.service.AppSettingService;
import com.passql.web.support.AdminAuditLogViewHelper;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 감사 로그 화면 보조(링크·전후 행), 접근 이벤트 기록, 설정 롤백 안전장치 (#623, #624) — 컨텍스트 없는 단위 테스트 */
class AdminAuditViewAndHistoryTest {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Test
    void 대상_ID가_UUID면_상세_아니면_목록으로_링크한다() {
        AdminAuditLogViewHelper helper = new AdminAuditLogViewHelper(objectMapper);
        UUID questionUuid = UUID.randomUUID();

        assertThat(helper.findTargetPath(AdminAuditTargetType.QUESTION, questionUuid.toString()))
                .isEqualTo("/admin/questions/" + questionUuid);
        assertThat(helper.findTargetPath(AdminAuditTargetType.QUESTION, "not-a-uuid")).isEqualTo("/admin/questions");
        assertThat(helper.findTargetPath(AdminAuditTargetType.APP_SETTING, "ai.max_tokens"))
                .isEqualTo("/admin/settings?keyword=ai.max_tokens");
    }

    @Test
    void 변경_요약을_필드별_전후_행으로_바꾸고_바뀐_필드를_표시한다() {
        AdminAuditLogViewHelper helper = new AdminAuditLogViewHelper(objectMapper);

        var rows = helper.toChangeRows("{\"before\":{\"role\":\"VIEWER\",\"isEnabled\":true},\"after\":{\"role\":\"ADMIN\",\"isEnabled\":true}}");

        assertThat(rows).hasSize(2);
        assertThat(rows.get(0).fieldName()).isEqualTo("role");
        assertThat(rows.get(0).beforeText()).isEqualTo("VIEWER");
        assertThat(rows.get(0).afterText()).isEqualTo("ADMIN");
        assertThat(rows.get(0).isChanged()).isTrue();
        assertThat(rows.get(1).isChanged()).isFalse();
        // 길이 제한으로 잘린 JSON 은 빈 목록 (화면이 원문으로 대체)
        assertThat(helper.toChangeRows("{\"before\":{\"a\":\"x")).isEmpty();
    }

    @Test
    void 접근_이벤트는_제어문자를_제거하고_길이를_제한해_저장한다() {
        AdminAuditLogRepository repository = mock(AdminAuditLogRepository.class);
        AdminAuditLogService service = new AdminAuditLogService(repository, objectMapper);

        service.recordAccessEvent("op\nerator" + "x".repeat(80), null, AdminAuditAction.LOGIN_FAILURE,
                Map.of("reason", "bad_credentials"), "10.0.0.1");

        ArgumentCaptor<AdminAuditLog> saved = ArgumentCaptor.forClass(AdminAuditLog.class);
        verify(repository).save(saved.capture());
        assertThat(saved.getValue().getAdminUsername()).hasSize(50).startsWith("operator");
        assertThat(saved.getValue().getAction()).isEqualTo(AdminAuditAction.LOGIN_FAILURE);
        assertThat(saved.getValue().getTargetType()).isEqualTo(AdminAuditTargetType.ADMIN_ACCOUNT);
        assertThat(saved.getValue().getChangeSummaryJson()).contains("bad_credentials");
    }

    @Test
    void 민감_키_설정은_롤백을_거부하고_일반_키는_이전_값으로_저장한다() {
        AdminAuditLogRepository repository = mock(AdminAuditLogRepository.class);
        AppSettingService appSettingService = mock(AppSettingService.class);
        AppSettingHistoryService service = new AppSettingHistoryService(repository, appSettingService, objectMapper);

        UUID sensitiveLogUuid = UUID.randomUUID();
        when(repository.findById(sensitiveLogUuid)).thenReturn(Optional.of(
                AdminAuditLog.of("operator", AdminAuditTargetType.APP_SETTING, "ai.gemini_api_key", AdminAuditAction.UPDATE,
                        "{\"before\":{\"value\":\"***abc\"},\"after\":{\"value\":\"***def\"}}", null)));
        assertThatThrownBy(() -> service.rollback("ai.gemini_api_key", sensitiveLogUuid)).isInstanceOf(CustomException.class);

        UUID plainLogUuid = UUID.randomUUID();
        when(repository.findById(plainLogUuid)).thenReturn(Optional.of(
                AdminAuditLog.of("operator", AdminAuditTargetType.APP_SETTING, "sandbox.sql_max_length", AdminAuditAction.UPDATE,
                        "{\"before\":{\"value\":\"2000\"},\"after\":{\"value\":\"3000\"}}", null)));
        service.rollback("sandbox.sql_max_length", plainLogUuid);

        verify(appSettingService).save("sandbox.sql_max_length", "2000");
        verify(appSettingService, never()).save("ai.gemini_api_key", "***abc");
    }
}
