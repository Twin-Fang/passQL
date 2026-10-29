package com.passql.meta.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.constant.AppSettingValueType;
import com.passql.meta.crypto.SettingSecretCipher;
import com.passql.meta.dto.AppLinksResponse;
import com.passql.meta.dto.SettingView;
import com.passql.meta.entity.AppSetting;
import com.passql.meta.repository.AppSettingRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Sort;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Optional;
import java.util.Set;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AppSettingService {

    public static final String REDIS_PREFIX = "passql:settings:";

    // settingKey 구분자(. _ -) 단위 조각이 이 단어로 끝나면 값을 마스킹 처리
    private static final Set<String> MASK_KEYWORDS = Set.of("key", "secret", "password", "token");
    // SECRET 목록 표시 문구 (긴 값도 마스크 대신 설정 여부만)
    static final String SECRET_CONFIGURED_LABEL = "설정됨";
    static final String SECRET_NOT_CONFIGURED_LABEL = "미설정";

    private final AppSettingRepository appSettingRepository;
    private final StringRedisTemplate redisTemplate;
    private final ApplicationEventPublisher eventPublisher;
    private final SettingSecretCipher secretCipher;

    public String getString(String key) {
        String cached = redisTemplate.opsForValue().get(REDIS_PREFIX + key);
        if (cached != null) return cached;

        String value = appSettingRepository.findBySettingKey(key)
                .map(AppSetting::getValueText)
                .orElseThrow(() -> new CustomException(ErrorCode.SETTING_NOT_FOUND));

        redisTemplate.opsForValue().set(REDIS_PREFIX + key, value);
        return value;
    }

    /** 비밀 설정 평문 (암호문이면 복호화, 전환 전 평문은 그대로) */
    public String getSecret(String key) {
        return decryptIfEncrypted(key, getString(key));
    }

    private String decryptIfEncrypted(String key, String storedValue) {
        return SettingSecretCipher.isEncrypted(storedValue) ? secretCipher.decrypt(key, storedValue) : storedValue;
    }

    /** 공개 스토어 링크. 비었거나 https 가 아니면 null — 잘못 넣은 값이 웹 링크로 나가지 않게 한다. */
    public AppLinksResponse getAppLinks() {
        return new AppLinksResponse(httpsUrlOrNull(AppSettingKeys.STORE_ANDROID_URL), httpsUrlOrNull(AppSettingKeys.STORE_IOS_URL));
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

    public boolean getBoolean(String key) { return Boolean.parseBoolean(getString(key).trim()); }

    /** 정수 설정 (행 없음·형식 오류는 기본값 — 설정 장애로 부가 기능이 멈추지 않게) */
    public int getIntOrDefault(String key, int defaultValue) {
        try {
            return getInt(key);
        } catch (CustomException e) {
            return defaultValue;
        } catch (NumberFormatException e) {
            // 값은 남기지 않음 (키 이름만)
            log.warn("[app-setting get-int] default used : invalid integer format : key={}, default={}", key, defaultValue);
            return defaultValue;
        }
    }

    /** 불리언 설정 (행 없음은 기본값, true/false 외 값은 false) */
    public boolean getBooleanOrDefault(String key, boolean defaultValue) {
        String value;
        try {
            value = getString(key).trim();
        } catch (CustomException e) {
            return defaultValue;
        }
        if (!isBooleanText(value)) {
            log.warn("[app-setting get-boolean] treated as false : invalid boolean format : key={}", key);
        }
        return Boolean.parseBoolean(value);
    }

    private static boolean isBooleanText(String value) {
        return "true".equalsIgnoreCase(value) || "false".equalsIgnoreCase(value);
    }

    public List<AppSetting> findAll() {
        return appSettingRepository.findAll(Sort.by("category", "settingKey"));
    }

    /** 마스킹 처리된 SettingView 목록 반환 — Controller에 변환 로직 두지 않음 */
    public List<SettingView> findAllAsView() {
        return findAll().stream()
                .map(s -> {
                    // 키 이름 기준 민감 + SECRET 타입 (키 이름에 key/token 이 없는 비밀값도 마스킹·비밀 저장 경로)
                    boolean isSensitive = isSensitiveKey(s.getSettingKey()) || isSecretSetting(s);
                    return new SettingView(
                            s.getSettingKey(),
                            s.getValueType(),
                            toDisplayValue(s, isSensitive),
                            s.getCategory(),
                            s.getDescription(),
                            isSensitive,
                            AppSettingKeys.isRestartRequired(s.getSettingKey())
                    );
                })
                .toList();
    }

    /** 목록 표시값: SECRET > 설정됨·미설정, 그 외 민감 > 마스킹, 일반 > 원문 */
    private String toDisplayValue(AppSetting setting, boolean isSensitive) {
        if (isSecretSetting(setting)) {
            return StringUtils.hasText(setting.getValueText()) ? SECRET_CONFIGURED_LABEL : SECRET_NOT_CONFIGURED_LABEL;
        }
        return isSensitive ? toMaskedDisplayValue(setting) : setting.getValueText();
    }

    /** 민감 값 표시용: 복호화 후 마스킹 (비어 있으면 빈 칸, 복호화 실패는 안내 문구) */
    private String toMaskedDisplayValue(AppSetting setting) {
        String stored = setting.getValueText();
        if (!StringUtils.hasText(stored)) return "";
        try {
            return maskValue(decryptIfEncrypted(setting.getSettingKey(), stored));
        } catch (CustomException e) {
            return "(복호화 실패)";
        }
    }

    /** 설정 저장: 행 조회 > value_type 형식 검사 > DB·Redis 반영 */
    @Transactional
    public void save(String key, String value) {
        AppSetting setting = appSettingRepository.findBySettingKey(key)
                .orElseThrow(() -> new CustomException(ErrorCode.SETTING_NOT_FOUND));
        // 비밀값은 saveSecret 으로만 저장 (평문 저장 방지)
        if (isSecretSetting(setting)) {
            throw new CustomException(ErrorCode.SETTING_SENSITIVE_UPDATE_FORBIDDEN);
        }
        validateValueMatchesType(setting, value);
        String previousValue = setting.getValueText();
        setting.setValueText(value);
        appSettingRepository.save(setting);
        redisTemplate.opsForValue().set(REDIS_PREFIX + key, value);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.APP_SETTING, key, AdminAuditAction.UPDATE,
                AdminAuditEvent.summary("value", toAuditValue(key, previousValue)),
                AdminAuditEvent.summary("value", toAuditValue(key, value))));
    }

    /** 비밀 설정 저장: 행 조회 > SECRET 확인 > 빈 값 거부 > 암호화 > DB·Redis 반영 (감사 기록은 마스킹) */
    @Transactional
    public void saveSecret(String key, String plainValue) {
        AppSetting setting = appSettingRepository.findBySettingKey(key)
                .orElseThrow(() -> new CustomException(ErrorCode.SETTING_NOT_FOUND));
        if (!isSecretSetting(setting)) {
            throw new CustomException(ErrorCode.SETTING_SENSITIVE_UPDATE_FORBIDDEN);
        }
        if (!StringUtils.hasText(plainValue)) {
            log.warn("[app-setting save-secret] rejected 400 : empty value : key={}", key);
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, key + " 값은 비워둘 수 없습니다.");
        }
        String trimmedValue = plainValue.trim();
        String previousStored = setting.getValueText();
        String encrypted = secretCipher.encrypt(key, trimmedValue);
        setting.setValueText(encrypted);
        appSettingRepository.save(setting);
        redisTemplate.opsForValue().set(REDIS_PREFIX + key, encrypted);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.APP_SETTING, key, AdminAuditAction.UPDATE,
                AdminAuditEvent.summary("value", StringUtils.hasText(previousStored) ? "***" : ""),
                AdminAuditEvent.summary("value", maskValue(trimmedValue))));
    }

    /** 비밀 설정 평문 (행 없음·값 없음·복호화 실패 > empty, 기존 값 이관용) */
    public Optional<String> findSecret(String key) {
        try {
            return appSettingRepository.findBySettingKey(key)
                    .map(AppSetting::getValueText)
                    .filter(StringUtils::hasText)
                    .map(storedValue -> decryptIfEncrypted(key, storedValue));
        } catch (CustomException e) {
            log.warn("[app-setting find-secret] skipped : decrypt failed : key={}", key);
            return Optional.empty();
        }
    }

    /** 설정 행 삭제 (DB·Redis, 다른 기능으로 옮긴 설정 정리용) */
    @Transactional
    public void deleteSetting(String key) {
        appSettingRepository.findBySettingKey(key).ifPresent(appSettingRepository::delete);
        redisTemplate.delete(REDIS_PREFIX + key);
        log.info("[app-setting delete] removed : key={}", key);
    }

    /**
     * 기동 시 비밀 설정 동기화: DB 평문 > 암호화로 전환, 암호문 > Redis 적재, 비어 있음 > 기본값(yml) 암호화 후 채움
     * 행 없음·기본값 없음은 경고만
     */
    @Transactional
    public void syncSecretSetting(String key, String defaultPlainValue) {
        Optional<AppSetting> settingOptional = appSettingRepository.findBySettingKey(key);
        if (settingOptional.isEmpty()) {
            log.warn("[app-setting sync-secret] skipped : row missing, check migration : key={}", key);
            return;
        }
        AppSetting setting = settingOptional.get();
        String stored = setting.getValueText();

        // 이미 암호문 (이중 암호화 방지)
        if (SettingSecretCipher.isEncrypted(stored)) {
            redisTemplate.opsForValue().set(REDIS_PREFIX + key, stored);
            log.info("[app-setting sync-secret] warmed up : DB -> Redis : key={}", key);
            return;
        }

        // 평문 또는 비어 있음 > 평문 원본 결정 (DB 우선, 없으면 yml)
        String plainValue = StringUtils.hasText(stored) ? stored : defaultPlainValue;
        if (!StringUtils.hasText(plainValue)) {
            log.warn("[app-setting sync-secret] skipped : DB and default both empty : key={}", key);
            return;
        }
        String encrypted = secretCipher.encrypt(key, plainValue.trim());
        setting.setValueText(encrypted);
        appSettingRepository.save(setting);
        redisTemplate.opsForValue().set(REDIS_PREFIX + key, encrypted);
        log.info("[app-setting sync-secret] encrypted : {} -> DB, Redis : key={}",
                StringUtils.hasText(stored) ? "legacy plaintext" : "default", key);
    }

    private static boolean isSecretSetting(AppSetting setting) {
        return AppSettingValueType.fromValueType(setting.getValueType()) == AppSettingValueType.SECRET;
    }

    /** 감사 기록용 값 (민감 키는 마스킹) */
    private static String toAuditValue(String key, String value) {
        return isSensitiveKey(key) ? maskValue(value) : value;
    }

    /** 형식이 틀린 값 거부 (저장되면 getInt 등 읽는 쪽이 전부 500) */
    private void validateValueMatchesType(AppSetting setting, String value) {
        AppSettingValueType valueType = AppSettingValueType.fromValueType(setting.getValueType());
        if (!valueType.isValidValue(value)) {
            log.warn("[app-setting save] rejected 400 : value type mismatch : key={}, valueType={}",
                    setting.getSettingKey(), valueType);
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE,
                    setting.getSettingKey() + " 값은 " + valueType + " 형식이어야 합니다.");
        }
    }

    /**
     * 기동 시 설정 동기화: DB 값 있음 > Redis 적재, DB 비어 있음 > 기본값을 DB·Redis 에 적재
     * 행 없음(마이그레이션 누락)·기본값 없음은 경고만
     */
    @Transactional
    public void syncSettingToRedis(String key, String defaultValue) {
        Optional<AppSetting> settingOptional = appSettingRepository.findBySettingKey(key);
        if (settingOptional.isEmpty()) {
            log.warn("[app-setting sync] skipped : row missing, check migration : key={}", key);
            return;
        }
        AppSetting setting = settingOptional.get();

        // DB 값 우선 (DB가 원본)
        if (StringUtils.hasText(setting.getValueText())) {
            redisTemplate.opsForValue().set(REDIS_PREFIX + key, setting.getValueText());
            log.info("[app-setting sync] warmed up : DB -> Redis : key={}", key);
            return;
        }

        // DB 비어 있음 > 기본값(yml) 적재
        if (!StringUtils.hasText(defaultValue)) {
            log.warn("[app-setting sync] skipped : DB and default both empty : key={}", key);
            return;
        }
        setting.setValueText(defaultValue);
        appSettingRepository.save(setting);
        redisTemplate.opsForValue().set(REDIS_PREFIX + key, defaultValue);
        log.info("[app-setting sync] filled : default -> DB, Redis : key={}, value={}",
                key, isSensitiveKey(key) ? maskValue(defaultValue) : defaultValue);
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
