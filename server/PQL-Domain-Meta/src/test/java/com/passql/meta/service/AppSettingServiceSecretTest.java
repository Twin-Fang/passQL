package com.passql.meta.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.crypto.SettingSecretCipher;
import com.passql.meta.crypto.SettingSecretCipherTest;
import com.passql.meta.dto.SettingView;
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
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 비밀 설정 저장·읽기·기동 전환 (#492): DB·Redis 에는 암호문만, 목록에는 원문 미노출 */
class AppSettingServiceSecretTest {

    private static final String KEY = AppSettingKeys.AI_GEMINI_API_KEY;

    private AppSettingRepository repository;
    private ValueOperations<String, String> redisValues;
    private SettingSecretCipher cipher;
    private AppSettingService service;

    @BeforeEach
    @SuppressWarnings("unchecked")
    void setUp() {
        repository = mock(AppSettingRepository.class);
        StringRedisTemplate redis = mock(StringRedisTemplate.class);
        redisValues = mock(ValueOperations.class);
        when(redis.opsForValue()).thenReturn(redisValues);
        cipher = new SettingSecretCipher(SettingSecretCipherTest.TEST_MASTER_KEY);
        service = new AppSettingService(repository, redis, event -> { }, cipher);
    }

    @Test
    void saveSecret은_DB와_Redis에_암호문만_저장() {
        AppSetting setting = givenSecretRow("");

        service.saveSecret(KEY, "  AIza-new-key  ");

        assertThat(setting.getValueText()).startsWith("enc:v1:").doesNotContain("AIza-new-key");
        assertThat(cipher.decrypt(KEY, setting.getValueText())).isEqualTo("AIza-new-key");
        verify(redisValues).set(eq(AppSettingService.REDIS_PREFIX + KEY), eq(setting.getValueText()));
    }

    @Test
    void 빈_값과_공백만_있는_값은_400으로_거부() {
        AppSetting setting = givenSecretRow("enc:v1:old");

        for (String blank : new String[]{"", "   ", null}) {
            assertThatThrownBy(() -> service.saveSecret(KEY, blank))
                    .isInstanceOf(CustomException.class)
                    .extracting(e -> ((CustomException) e).getErrorCode())
                    .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
        }
        assertThat(setting.getValueText()).isEqualTo("enc:v1:old");
        verify(repository, never()).save(any());
    }

    @Test
    void SECRET이_아닌_행은_saveSecret으로_저장_거부() {
        when(repository.findBySettingKey(AppSettingKeys.STORE_IOS_URL)).thenReturn(Optional.of(AppSetting.builder()
                .settingKey(AppSettingKeys.STORE_IOS_URL).valueType("STRING").valueText("").build()));

        assertThatThrownBy(() -> service.saveSecret(AppSettingKeys.STORE_IOS_URL, "x"))
                .isInstanceOf(CustomException.class)
                .extracting(e -> ((CustomException) e).getErrorCode())
                .isEqualTo(ErrorCode.SETTING_SENSITIVE_UPDATE_FORBIDDEN);
    }

    @Test
    void SECRET_행은_일반_save로_수정_불가() {
        givenSecretRow("enc:v1:old");

        assertThatThrownBy(() -> service.save(KEY, "plain"))
                .isInstanceOf(CustomException.class)
                .extracting(e -> ((CustomException) e).getErrorCode())
                .isEqualTo(ErrorCode.SETTING_SENSITIVE_UPDATE_FORBIDDEN);
        verify(repository, never()).save(any());
    }

    @Test
    void getSecret은_암호문을_복호화하고_평문_행은_그대로_반환() {
        when(redisValues.get(AppSettingService.REDIS_PREFIX + KEY)).thenReturn(cipher.encrypt(KEY, "AIza-1"));
        assertThat(service.getSecret(KEY)).isEqualTo("AIza-1");

        when(redisValues.get(AppSettingService.REDIS_PREFIX + KEY)).thenReturn("legacy-plain");
        assertThat(service.getSecret(KEY)).isEqualTo("legacy-plain");
    }

    @Test
    void 목록에는_원문_대신_설정_여부만_노출() {
        AppSetting configured = givenSecretRow(cipher.encrypt(KEY, "AIza-secret-123"));
        AppSetting empty = AppSetting.builder().settingKey(AppSettingKeys.BILLING_PLAY_SERVICE_ACCOUNT_JSON)
                .valueType("SECRET").valueText("").build();
        when(repository.findAll(any(Sort.class))).thenReturn(List.of(configured, empty));

        List<SettingView> views = service.findAllAsView();

        assertThat(views.get(0).valueText()).isEqualTo(AppSettingService.SECRET_CONFIGURED_LABEL);
        // 키 이름에 민감 단어가 없어도 SECRET 이면 비밀 편집 경로
        assertThat(views.get(1).valueText()).isEqualTo(AppSettingService.SECRET_NOT_CONFIGURED_LABEL);
        assertThat(views.get(1).sensitive()).isTrue();
    }

    @Test
    void 기동_시_평문은_암호화로_전환() {
        AppSetting setting = givenSecretRow("AIza-legacy");

        service.syncSecretSetting(KEY, "yml-key");

        assertThat(cipher.decrypt(KEY, setting.getValueText())).isEqualTo("AIza-legacy");
        verify(redisValues).set(eq(AppSettingService.REDIS_PREFIX + KEY), eq(setting.getValueText()));
    }

    @Test
    void 기동_시_이미_암호문이면_이중_암호화하지_않음() {
        String encrypted = cipher.encrypt(KEY, "AIza-1");
        AppSetting setting = givenSecretRow(encrypted);

        service.syncSecretSetting(KEY, "yml-key");

        assertThat(setting.getValueText()).isEqualTo(encrypted);
        verify(repository, never()).save(any());
        verify(redisValues).set(eq(AppSettingService.REDIS_PREFIX + KEY), eq(encrypted));
    }

    @Test
    void 기동_시_DB가_비면_yml_값을_암호화해_채움() {
        AppSetting setting = givenSecretRow("");

        service.syncSecretSetting(KEY, "yml-key");

        assertThat(cipher.decrypt(KEY, setting.getValueText())).isEqualTo("yml-key");
    }

    @Test
    void 기동_시_DB와_yml_모두_비면_아무것도_저장하지_않음() {
        givenSecretRow("");

        service.syncSecretSetting(KEY, "");

        verify(repository, never()).save(any());
    }

    private AppSetting givenSecretRow(String valueText) {
        AppSetting setting = AppSetting.builder().settingKey(KEY).valueType("SECRET").valueText(valueText).build();
        when(repository.findBySettingKey(KEY)).thenReturn(Optional.of(setting));
        return setting;
    }
}
