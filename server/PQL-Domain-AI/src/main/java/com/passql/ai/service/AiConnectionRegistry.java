package com.passql.ai.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.passql.ai.constant.AiProvider;
import com.passql.ai.dto.AiConnectionTarget;
import com.passql.ai.entity.AiConnection;
import com.passql.ai.repository.AiConnectionRepository;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.crypto.SettingSecretCipher;
import com.passql.meta.service.AppSettingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * AI 연결 호출용 저장소: 사용 중 연결 목록(30초 캐시), AI 서버 공유(Redis), 호출 결과 기록, 기존 키 이관 (#695)
 * Redis 형식: passql:ai:connections = [{connection_uuid, connection_name, provider, default_model, encrypted_api_key}] (우선순위 순)
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AiConnectionRegistry {

    // AI 서버가 읽는 연결 목록 키 (ai/src/clients/ai_connection_store.py 와 같은 값)
    public static final String REDIS_CONNECTIONS_KEY = "passql:ai:connections";
    // 호출용 목록 캐시 유지 시간 (30초, 다른 인스턴스 변경도 이 안에 반영)
    private static final long CALL_TARGET_CACHE_MILLISECONDS = 30_000;
    // 기존 키 이관 시 기본 연결 (Claude 1순위, Gemini 2순위)
    static final String LEGACY_CLAUDE_CONNECTION_NAME = "claude-passql-pro";
    static final String LEGACY_CLAUDE_DEFAULT_MODEL = "claude-haiku-5-5";
    static final String LEGACY_GEMINI_CONNECTION_NAME = "gemini-default";
    static final String LEGACY_GEMINI_DEFAULT_MODEL = "gemini-2.5-flash-lite";

    private final AiConnectionRepository aiConnectionRepository;
    private final SettingSecretCipher settingSecretCipher;
    private final StringRedisTemplate stringRedisTemplate;
    private final AppSettingService appSettingService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    private volatile CachedCallTargets cachedCallTargets;

    private record CachedCallTargets(List<AiConnectionTarget> targets, long loadedAtMilliseconds) {
    }

    /** 사용 중 연결 (우선순위 순, 키 복호화, 30초 캐시) */
    public List<AiConnectionTarget> findCallTargets() {
        CachedCallTargets cached = cachedCallTargets;
        if (cached != null && System.currentTimeMillis() - cached.loadedAtMilliseconds() < CALL_TARGET_CACHE_MILLISECONDS) {
            return cached.targets();
        }
        List<AiConnectionTarget> targets = new ArrayList<>();
        for (AiConnection connection : aiConnectionRepository.findAllByOrderByPriorityAscCreatedAtAsc()) {
            if (Boolean.TRUE.equals(connection.getIsEnabled())) {
                toCallTarget(connection).ifPresent(targets::add);
            }
        }
        cachedCallTargets = new CachedCallTargets(List.copyOf(targets), System.currentTimeMillis());
        return cachedCallTargets.targets();
    }

    /** 연결 1건 > 호출 대상 (복호화 실패는 건너뜀, 로그에 이름만) */
    public Optional<AiConnectionTarget> toCallTarget(AiConnection connection) {
        try {
            String apiKey = settingSecretCipher.decrypt(AiConnection.toEncryptionKey(connection.getAiConnectionUuid()),
                    connection.getEncryptedApiKey());
            return Optional.of(new AiConnectionTarget(connection.getAiConnectionUuid(), connection.getConnectionName(),
                    connection.getProvider(), apiKey, connection.getDefaultModel()));
        } catch (RuntimeException e) {
            log.error("[ai connection] skipped : decrypt failed : name={}", connection.getConnectionName());
            return Optional.empty();
        }
    }

    /** 연결 변경 후: 캐시 비움 > AI 서버용 Redis 목록 갱신 */
    public void refreshAfterChange() {
        cachedCallTargets = null;
        syncConnectionsToRedis();
    }

    /** AI 서버용 Redis 목록 갱신 (사용 중 연결만, 키는 암호문 그대로) */
    public void syncConnectionsToRedis() {
        ArrayNode connectionArray = objectMapper.createArrayNode();
        for (AiConnection connection : aiConnectionRepository.findAllByOrderByPriorityAscCreatedAtAsc()) {
            if (!Boolean.TRUE.equals(connection.getIsEnabled())) {
                continue;
            }
            connectionArray.addObject()
                    .put("connection_uuid", connection.getAiConnectionUuid().toString())
                    .put("connection_name", connection.getConnectionName())
                    .put("provider", connection.getProvider().name())
                    .put("default_model", connection.getDefaultModel())
                    .put("encrypted_api_key", connection.getEncryptedApiKey());
        }
        stringRedisTemplate.opsForValue().set(REDIS_CONNECTIONS_KEY, connectionArray.toString());
        log.info("[ai connection] synced to redis : count={}", connectionArray.size());
    }

    /** 호출 성공 기록 (요청 흐름과 분리, 실패해도 무시) */
    @Async(AiCallLogService.RECORD_EXECUTOR_NAME)
    @Transactional
    public void recordSuccess(UUID aiConnectionUuid) {
        try {
            aiConnectionRepository.updateLastSuccess(aiConnectionUuid, LocalDateTime.now());
        } catch (Exception e) {
            log.warn("[ai connection] record success failed : {}", e.getClass().getSimpleName());
        }
    }

    /** 호출 실패 기록 (마지막 오류 종류) */
    @Async(AiCallLogService.RECORD_EXECUTOR_NAME)
    @Transactional
    public void recordFailure(UUID aiConnectionUuid, String errorType) {
        try {
            aiConnectionRepository.updateLastFailure(aiConnectionUuid, LocalDateTime.now(), errorType);
        } catch (Exception e) {
            log.warn("[ai connection] record failure failed : {}", e.getClass().getSimpleName());
        }
    }

    /**
     * 기존 키 이관 (연결이 하나도 없을 때 1회): 앱 설정 키 > 없으면 yml 키 > 연결 생성 > 앱 설정 행 삭제
     * 순서: Claude 1순위(claude-haiku-5-5), Gemini 2순위(gemini-2.5-flash-lite)
     */
    @Transactional
    public void importLegacyKeysIfEmpty(String claudeApiKeyFromYml, String geminiApiKeyFromYml) {
        if (aiConnectionRepository.count() > 0) {
            deleteLegacyKeySettings();
            return;
        }
        int priority = 1;
        Optional<String> claudeApiKey = appSettingService.findSecret(AppSettingKeys.AI_CLAUDE_API_KEY)
                .or(() -> Optional.ofNullable(claudeApiKeyFromYml)).filter(StringUtils::hasText);
        if (claudeApiKey.isPresent()) {
            createImportedConnection(AiProvider.CLAUDE, LEGACY_CLAUDE_CONNECTION_NAME, claudeApiKey.get(),
                    LEGACY_CLAUDE_DEFAULT_MODEL, priority++);
        }
        Optional<String> geminiApiKey = appSettingService.findSecret(AppSettingKeys.AI_GEMINI_API_KEY)
                .or(() -> Optional.ofNullable(geminiApiKeyFromYml)).filter(StringUtils::hasText);
        if (geminiApiKey.isPresent()) {
            createImportedConnection(AiProvider.GEMINI, LEGACY_GEMINI_CONNECTION_NAME, geminiApiKey.get(),
                    LEGACY_GEMINI_DEFAULT_MODEL, priority);
        }
        // 하나라도 옮겼을 때만 정리 (못 옮긴 키는 앱 설정에 남겨 둠)
        if (aiConnectionRepository.count() > 0) {
            deleteLegacyKeySettings();
        }
    }

    private void createImportedConnection(AiProvider provider, String connectionName, String apiKey,
                                          String defaultModel, int priority) {
        UUID aiConnectionUuid = UUID.randomUUID();
        String encryptedApiKey = settingSecretCipher.encrypt(AiConnection.toEncryptionKey(aiConnectionUuid), apiKey.strip());
        aiConnectionRepository.save(AiConnection.create(aiConnectionUuid, provider, connectionName, encryptedApiKey,
                defaultModel, priority));
        log.info("[ai connection] imported legacy key : name={}, priority={}", connectionName, priority);
    }

    // 연결로 옮긴 앱 설정 키 2개 정리 (이관 후 같은 값이 두 군데 남지 않게)
    private void deleteLegacyKeySettings() {
        appSettingService.deleteSetting(AppSettingKeys.AI_CLAUDE_API_KEY);
        appSettingService.deleteSetting(AppSettingKeys.AI_GEMINI_API_KEY);
    }
}
