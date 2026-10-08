package com.passql.meta.service;

import com.passql.meta.dto.AppLinksResponse;
import com.passql.meta.entity.AppSetting;
import com.passql.meta.repository.AppSettingRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/** 웹 앱 출시 안내는 이 값으로 노출 여부가 갈린다 — 잘못된 값이 링크로 나가면 안 된다 (#433). */
class AppSettingServiceAppLinksTest {

    private AppSettingRepository repository;
    private AppSettingService service;

    @BeforeEach
    void setUp() {
        repository = mock(AppSettingRepository.class);
        StringRedisTemplate redis = mock(StringRedisTemplate.class);
        @SuppressWarnings("unchecked")
        ValueOperations<String, String> ops = mock(ValueOperations.class);
        when(redis.opsForValue()).thenReturn(ops);
        when(ops.get(anyString())).thenReturn(null); // 캐시 미스 → DB 조회 경로
        service = new AppSettingService(repository, redis);
    }

    private void stub(String key, String value) {
        AppSetting setting = mock(AppSetting.class);
        when(setting.getValueText()).thenReturn(value);
        when(repository.findBySettingKey(key)).thenReturn(Optional.of(setting));
    }

    @Test
    void 출시_전_빈_값이면_둘_다_null() {
        stub(AppSettingService.STORE_ANDROID_URL, "");
        stub(AppSettingService.STORE_IOS_URL, "  ");

        assertThat(service.getAppLinks()).isEqualTo(new AppLinksResponse(null, null));
    }

    @Test
    void https_링크만_내보내고_공백은_다듬는다() {
        stub(AppSettingService.STORE_ANDROID_URL, " https://play.google.com/store/apps/details?id=com.coldredrice.passql ");
        stub(AppSettingService.STORE_IOS_URL, "javascript:alert(1)");

        AppLinksResponse links = service.getAppLinks();

        assertThat(links.androidUrl()).isEqualTo("https://play.google.com/store/apps/details?id=com.coldredrice.passql");
        assertThat(links.iosUrl()).isNull();
    }

    @Test
    void 설정_행이_없어도_예외_없이_null() {
        when(repository.findBySettingKey(anyString())).thenReturn(Optional.empty());

        assertThat(service.getAppLinks()).isEqualTo(new AppLinksResponse(null, null));
    }
}
