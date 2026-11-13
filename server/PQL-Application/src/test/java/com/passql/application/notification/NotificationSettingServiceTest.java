package com.passql.application.notification;

import com.passql.common.exception.CustomException;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 회원당 하루 자동 알림 상한 판정 (#649): 범위 밖 설정값 > 기본 1건, 범위 밖 저장 > 거부
 */
class NotificationSettingServiceTest {

    private final AppSettingService appSettingService = mock(AppSettingService.class);
    private final NotificationSettingService notificationSettingService = new NotificationSettingService(appSettingService);

    @Test
    void 설정값이_범위_안이면_그대로_쓴다() {
        when(appSettingService.getIntOrDefault(eq(AppSettingKeys.NOTIFICATION_AUTO_DAILY_LIMIT_PER_MEMBER), eq(1))).thenReturn(3);

        assertThat(notificationSettingService.getAutoDailyLimitPerMember()).isEqualTo(3);
    }

    @Test
    void 설정값이_범위_밖이면_기본_1건() {
        when(appSettingService.getIntOrDefault(eq(AppSettingKeys.NOTIFICATION_AUTO_DAILY_LIMIT_PER_MEMBER), eq(1))).thenReturn(0);

        assertThat(notificationSettingService.getAutoDailyLimitPerMember()).isEqualTo(1);
    }

    @Test
    void 범위_밖_상한은_저장하지_않는다() {
        assertThatThrownBy(() -> notificationSettingService.updateAutoDailyLimitPerMember(
                NotificationSettingService.MAX_AUTO_DAILY_LIMIT_PER_MEMBER + 1)).isInstanceOf(CustomException.class);
        assertThatThrownBy(() -> notificationSettingService.updateAutoDailyLimitPerMember(null)).isInstanceOf(CustomException.class);

        verify(appSettingService, never()).save(anyString(), anyString());
    }
}
