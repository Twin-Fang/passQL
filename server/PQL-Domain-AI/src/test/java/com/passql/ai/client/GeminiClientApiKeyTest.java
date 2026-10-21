package com.passql.ai.client;

import com.passql.ai.service.AiCallLogService;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/** Gemini 클라이언트 키 갱신 (#492): 키가 바뀌면 재생성, 같으면 재사용, 비면 거부 (네트워크 호출 없음) */
class GeminiClientApiKeyTest {

    private AppSettingService appSettingService;
    private GeminiClient geminiClient;

    @BeforeEach
    void setUp() {
        appSettingService = mock(AppSettingService.class);
        geminiClient = new GeminiClient(appSettingService, mock(AiCallLogService.class), "gemini-test-model");
    }

    @Test
    void 키가_같으면_같은_클라이언트를_재사용() {
        when(appSettingService.getSecret(AppSettingKeys.AI_GEMINI_API_KEY)).thenReturn("key-1");

        assertThat(geminiClient.resolveClient()).isSameAs(geminiClient.resolveClient());
    }

    @Test
    void 관리자_화면에서_키가_바뀌면_새_클라이언트() {
        when(appSettingService.getSecret(AppSettingKeys.AI_GEMINI_API_KEY)).thenReturn("key-1");
        Object before = geminiClient.resolveClient();

        when(appSettingService.getSecret(AppSettingKeys.AI_GEMINI_API_KEY)).thenReturn("key-2");

        assertThat(geminiClient.resolveClient()).isNotSameAs(before);
    }

    @Test
    void 키가_비어_있으면_AI_UNAVAILABLE() {
        when(appSettingService.getSecret(AppSettingKeys.AI_GEMINI_API_KEY)).thenReturn("  ");

        assertThatThrownBy(() -> geminiClient.resolveClient())
                .isInstanceOf(CustomException.class)
                .extracting(e -> ((CustomException) e).getErrorCode())
                .isEqualTo(ErrorCode.AI_UNAVAILABLE);
    }
}
