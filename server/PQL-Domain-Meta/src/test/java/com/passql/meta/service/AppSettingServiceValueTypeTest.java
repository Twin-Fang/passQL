package com.passql.meta.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.crypto.SettingSecretCipher;
import com.passql.meta.crypto.SettingSecretCipherTest;
import com.passql.meta.entity.AppSetting;
import com.passql.meta.repository.AppSettingRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.data.domain.Sort;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 설정 저장 값 형식 검사 (#473): 틀린 값이 저장돼 getInt 가 500 나는 일 방지 */
class AppSettingServiceValueTypeTest {

    private AppSettingRepository appSettingRepository;
    private AppSettingService appSettingService;

    @BeforeEach
    void setUp() {
        appSettingRepository = mock(AppSettingRepository.class);
        StringRedisTemplate redisTemplate = mock(StringRedisTemplate.class);
        @SuppressWarnings("unchecked")
        ValueOperations<String, String> valueOperations = mock(ValueOperations.class);
        when(redisTemplate.opsForValue()).thenReturn(valueOperations);
        appSettingService = new AppSettingService(appSettingRepository, redisTemplate, event -> { }, new SettingSecretCipher(SettingSecretCipherTest.TEST_MASTER_KEY));
    }

    @Test
    void INT_설정에_숫자가_아닌_값은_INVALID_INPUT_VALUE로_거부() {
        AppSetting setting = givenSetting(AppSettingKeys.SANDBOX_POOL_WAIT_SECONDS, "INT", "10");

        assertThatThrownBy(() -> appSettingService.save(AppSettingKeys.SANDBOX_POOL_WAIT_SECONDS, "ten"))
                .isInstanceOf(CustomException.class)
                .extracting(e -> ((CustomException) e).getErrorCode())
                .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
        assertThat(setting.getValueText()).isEqualTo("10");
        verify(appSettingRepository, never()).save(any());
    }

    @Test
    void 형식이_맞으면_저장() {
        AppSetting intSetting = givenSetting(AppSettingKeys.SANDBOX_POOL_WAIT_SECONDS, "INT", "10");
        appSettingService.save(AppSettingKeys.SANDBOX_POOL_WAIT_SECONDS, "30");
        assertThat(intSetting.getValueText()).isEqualTo("30");

        AppSetting stringSetting = givenSetting(AppSettingKeys.STORE_IOS_URL, "STRING", "");
        appSettingService.save(AppSettingKeys.STORE_IOS_URL, "https://apps.apple.com/app/x");
        assertThat(stringSetting.getValueText()).isEqualTo("https://apps.apple.com/app/x");
    }

    @Test
    void 기동_시_1회_읽는_설정은_재시작_필요로_표시() {
        when(appSettingRepository.findAll(any(Sort.class))).thenReturn(List.of(AppSetting.builder()
                .settingKey(AppSettingKeys.SANDBOX_POOL_CONCURRENCY).valueType("INT").valueText("4").build()));

        assertThat(appSettingService.findAllAsView().get(0).isRestartRequired()).isTrue();
    }

    private AppSetting givenSetting(String key, String valueType, String valueText) {
        AppSetting setting = AppSetting.builder().settingKey(key).valueType(valueType).valueText(valueText).build();
        when(appSettingRepository.findBySettingKey(key)).thenReturn(Optional.of(setting));
        return setting;
    }
}
