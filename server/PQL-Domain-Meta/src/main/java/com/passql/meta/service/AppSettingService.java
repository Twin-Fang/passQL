package com.passql.meta.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.dto.AppLinksResponse;
import com.passql.meta.dto.SettingView;
import com.passql.meta.entity.AppSetting;
import com.passql.meta.repository.AppSettingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AppSettingService {

    public static final String REDIS_PREFIX = "passql:settings:";

    // settingKey 구분자(. _ -) 단위 조각이 이 단어로 끝나면 값을 마스킹 처리
    private static final Set<String> MASK_KEYWORDS = Set.of("key", "secret", "password", "token");

    // 스토어 링크 — 출시 후 관리자 설정에서 URL만 넣으면 웹 안내가 노출된다 (#433)
    public static final String STORE_ANDROID_URL = "store.android_url";
    public static final String STORE_IOS_URL = "store.ios_url";

    private final AppSettingRepository appSettingRepository;
    private final StringRedisTemplate redisTemplate;

    public String getString(String key) {
        String cached = redisTemplate.opsForValue().get(REDIS_PREFIX + key);
        if (cached != null) return cached;

        String value = appSettingRepository.findBySettingKey(key)
                .map(AppSetting::getValueText)
                .orElseThrow(() -> new CustomException(ErrorCode.SETTING_NOT_FOUND));

        redisTemplate.opsForValue().set(REDIS_PREFIX + key, value);
        return value;
    }

    /** 공개 스토어 링크. 비었거나 https 가 아니면 null — 잘못 넣은 값이 웹 링크로 나가지 않게 한다. */
    public AppLinksResponse getAppLinks() {
        return new AppLinksResponse(httpsUrlOrNull(STORE_ANDROID_URL), httpsUrlOrNull(STORE_IOS_URL));
    }

    private String httpsUrlOrNull(String key) {
        String value;
        try {
            value = getString(key);
        } catch (CustomException e) {
            // 마이그레이션 전 환경에서도 공개 API 가 500 이 되지 않게 "링크 없음"으로 본다
            return null;
        }
        String trimmed = value == null ? "" : value.trim();
        return trimmed.startsWith("https://") ? trimmed : null;
    }

    public int getInt(String key) { return Integer.parseInt(getString(key)); }

    public boolean getBoolean(String key) { return Boolean.parseBoolean(getString(key)); }

    public List<AppSetting> findAll() {
        return appSettingRepository.findAll(Sort.by("category", "settingKey"));
    }

    /** 마스킹 처리된 SettingView 목록 반환 — Controller에 변환 로직 두지 않음 */
    public List<SettingView> findAllAsView() {
        return findAll().stream()
                .map(s -> {
                    boolean sensitive = isSensitiveKey(s.getSettingKey());
                    return new SettingView(
                            s.getSettingKey(),
                            s.getValueType(),
                            sensitive ? maskValue(s.getValueText()) : s.getValueText(),
                            s.getCategory(),
                            s.getDescription(),
                            sensitive
                    );
                })
                .toList();
    }

    @Transactional
    public void save(String key, String value) {
        AppSetting setting = appSettingRepository.findBySettingKey(key)
                .orElseThrow(() -> new CustomException(ErrorCode.SETTING_NOT_FOUND));
        setting.setValueText(value);
        appSettingRepository.save(setting);
        redisTemplate.opsForValue().set(REDIS_PREFIX + key, value);
    }

    /**
     * key의 조각 중 민감 키워드로 끝나는 것이 있으면 true — UI에서 마스킹 처리.
     * 단순 포함 검사는 ai.default_max_tokens 같은 일반 설정까지 잠갔다 (#408).
     */
    public static boolean isSensitiveKey(String key) {
        for (String part : key.toLowerCase().split("[._-]")) {
            for (String keyword : MASK_KEYWORDS) {
                if (part.endsWith(keyword)) return true;
            }
        }
        return false;
    }

    /** 민감 값 마스킹: 마지막 3자리만 보여주고 앞은 * 처리 */
    public static String maskValue(String value) {
        if (value == null || value.length() <= 3) return "***";
        return "*".repeat(value.length() - 3) + value.substring(value.length() - 3);
    }
}
