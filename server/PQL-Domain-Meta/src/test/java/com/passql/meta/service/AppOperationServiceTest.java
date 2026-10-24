package com.passql.meta.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.dto.AppConfigResponse;
import com.passql.meta.dto.AppLinksResponse;
import com.passql.meta.dto.AppOperationSettingsRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 앱 시작 설정: 기본값은 차단 없음, 잘못된 값·설정 장애에도 앱을 막지 않음 (#464) */
class AppOperationServiceTest {

    private AppSettingService appSettingService;
    private AppNoticeService appNoticeService;
    private AppOperationService service;

    @BeforeEach
    void setUp() {
        appSettingService = mock(AppSettingService.class);
        appNoticeService = mock(AppNoticeService.class);
        when(appSettingService.getAppLinks()).thenReturn(new AppLinksResponse("https://play.example", null));
        when(appNoticeService.getVisibleNotices()).thenReturn(List.of());
        service = new AppOperationService(appSettingService, appNoticeService);
    }

    @Test
    void 설정_행이_없으면_차단_없음_기본값() {
        when(appSettingService.getString(anyString())).thenThrow(new CustomException(ErrorCode.SETTING_NOT_FOUND));

        AppConfigResponse config = service.getAppConfig();

        assertThat(config.ios().minimumVersion()).isEqualTo("0.0.0");
        assertThat(config.android().recommendedVersion()).isEqualTo("0.0.0");
        assertThat(config.android().storeUrl()).isEqualTo("https://play.example");
        assertThat(config.maintenance().isUnderMaintenance()).isFalse();
        assertThat(config.maintenance().message()).isEmpty();
        assertThat(config.isAndroidBillingEnabled()).isFalse();
    }

    @Test
    void 결제_스위치가_켜져_있으면_내려준다() {
        when(appSettingService.getString(AppSettingKeys.BILLING_ANDROID_ENABLED)).thenReturn("true");

        assertThat(service.getAppConfig().isAndroidBillingEnabled()).isTrue();
    }

    @Test
    void 저장된_값과_잘못된_버전은_기본값으로() {
        when(appSettingService.getString(AppSettingKeys.APP_MINIMUM_VERSION_IOS)).thenReturn("1.2.3");
        when(appSettingService.getString(AppSettingKeys.APP_MINIMUM_VERSION_ANDROID)).thenReturn("1.2");
        when(appSettingService.getString(AppSettingKeys.APP_RECOMMENDED_VERSION_IOS)).thenReturn(" 1.3.0 ");
        when(appSettingService.getString(AppSettingKeys.APP_RECOMMENDED_VERSION_ANDROID)).thenReturn("abc");
        when(appSettingService.getString(AppSettingKeys.APP_MAINTENANCE_ENABLED)).thenReturn("true");
        when(appSettingService.getString(AppSettingKeys.APP_MAINTENANCE_MESSAGE)).thenReturn("서버 이전 중");

        AppConfigResponse config = service.getAppConfig();

        assertThat(config.ios().minimumVersion()).isEqualTo("1.2.3");
        assertThat(config.ios().recommendedVersion()).isEqualTo("1.3.0");
        assertThat(config.android().minimumVersion()).isEqualTo("0.0.0");
        assertThat(config.android().recommendedVersion()).isEqualTo("0.0.0");
        assertThat(config.maintenance().isUnderMaintenance()).isTrue();
        assertThat(config.maintenance().message()).isEqualTo("서버 이전 중");
    }

    @Test
    @SuppressWarnings("unchecked")
    void 응답_JSON_필드명은_앱_계약대로() throws Exception {
        when(appSettingService.getString(anyString())).thenThrow(new CustomException(ErrorCode.SETTING_NOT_FOUND));
        ObjectMapper objectMapper = new ObjectMapper().registerModule(new JavaTimeModule());

        Map<String, Object> json = objectMapper.readValue(objectMapper.writeValueAsString(service.getAppConfig()), Map.class);

        assertThat(json).containsKeys("ios", "android", "maintenance", "notices");
        assertThat((Map<String, Object>) json.get("maintenance")).containsKeys("isUnderMaintenance", "message");
        assertThat((Map<String, Object>) json.get("ios")).containsKeys("minimumVersion", "recommendedVersion", "storeUrl");
    }

    @Test
    void 버전_형식이_틀리면_아무것도_저장하지_않는다() {
        AppOperationSettingsRequest request = new AppOperationSettingsRequest("1.0.0", "1.0", "1.0.0", "1.0.0", true, "점검");

        assertThatThrownBy(() -> service.updateOperationSettings(request))
                .isInstanceOf(CustomException.class)
                .extracting("errorCode").isEqualTo(ErrorCode.APP_VERSION_FORMAT_INVALID);
        verify(appSettingService, never()).save(anyString(), anyString());
    }

    @Test
    void 정상_요청은_6개_키_저장() {
        service.updateOperationSettings(new AppOperationSettingsRequest(" 1.0.0", "1.1.0", "1.0.0", "1.1.0", true, " 점검 "));

        verify(appSettingService).save(AppSettingKeys.APP_MINIMUM_VERSION_IOS, "1.0.0");
        verify(appSettingService).save(AppSettingKeys.APP_MAINTENANCE_ENABLED, "true");
        verify(appSettingService).save(AppSettingKeys.APP_MAINTENANCE_MESSAGE, "점검");
    }

    @Test
    void 점검_예약_구간_안이면_스위치가_꺼져_있어도_점검() {
        when(appSettingService.getString(AppSettingKeys.APP_MAINTENANCE_ENABLED)).thenReturn("false");
        when(appSettingService.getString(AppSettingKeys.APP_MAINTENANCE_STARTS_AT)).thenReturn(LocalDateTime.now().minusHours(1).toString());
        when(appSettingService.getString(AppSettingKeys.APP_MAINTENANCE_ENDS_AT)).thenReturn(LocalDateTime.now().plusHours(1).toString());

        assertThat(service.isUnderMaintenance()).isTrue();
    }

    @Test
    void 점검_예약_종료가_지났으면_점검_아님() {
        when(appSettingService.getString(AppSettingKeys.APP_MAINTENANCE_STARTS_AT)).thenReturn(LocalDateTime.now().minusHours(2).toString());
        when(appSettingService.getString(AppSettingKeys.APP_MAINTENANCE_ENDS_AT)).thenReturn(LocalDateTime.now().minusHours(1).toString());

        assertThat(service.isUnderMaintenance()).isFalse();
    }

    @Test
    void 점검_예약은_종료만_지정하면_거부() {
        AppOperationSettingsRequest request = new AppOperationSettingsRequest("1.0.0", "1.0.0", "1.0.0", "1.0.0", false, "",
                null, LocalDateTime.now().plusHours(1));

        assertThatThrownBy(() -> service.updateOperationSettings(request))
                .isInstanceOf(CustomException.class)
                .extracting("errorCode").isEqualTo(ErrorCode.APP_MAINTENANCE_PERIOD_INVALID);
        verify(appSettingService, never()).save(anyString(), anyString());
    }
}
