package com.passql.ai.service;

import com.passql.ai.client.AiProviderClient;
import com.passql.ai.client.AiProviderException;
import com.passql.ai.constant.AiProvider;
import com.passql.ai.dto.AiConnectionHealth;
import com.passql.ai.dto.AiConnectionTarget;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

/**
 * AI 연결 확인: 연결 1건 모델 조회(과금 없음) > 결과, 1순위 연결 확인은 5분 캐시 (대시보드·모니터링) (#695)
 */
@Slf4j
@Service
public class AiConnectionHealthChecker {

    // 1순위 연결 확인 캐시 (5분)
    private static final long TOP_CONNECTION_HEALTH_CACHE_MINUTES = 5;
    private static final int QUOTA_EXCEEDED_STATUS_CODE = 429;
    private static final int UNAUTHORIZED_STATUS_CODE = 401;
    private static final int FORBIDDEN_STATUS_CODE = 403;

    private final AiConnectionRegistry aiConnectionRegistry;
    private final Map<AiProvider, AiProviderClient> providerClientByProvider = new EnumMap<>(AiProvider.class);
    private final Object topConnectionHealthLock = new Object();
    private volatile AiConnectionHealth cachedTopConnectionHealth;

    public AiConnectionHealthChecker(AiConnectionRegistry aiConnectionRegistry, List<AiProviderClient> providerClients) {
        this.aiConnectionRegistry = aiConnectionRegistry;
        providerClients.forEach(providerClient -> providerClientByProvider.put(providerClient.provider(), providerClient));
    }

    /** 연결 1건 확인 (키·기본 모델 조회 1회) */
    public AiConnectionHealth check(AiConnectionTarget connection) {
        long startedAtMilliseconds = System.currentTimeMillis();
        try {
            providerClientByProvider.get(connection.provider()).verifyConnection(connection.apiKey(), connection.defaultModel());
            return new AiConnectionHealth(true, System.currentTimeMillis() - startedAtMilliseconds,
                    connection.connectionName() + " · " + connection.defaultModel() + " 확인", LocalDateTime.now());
        } catch (AiProviderException e) {
            log.warn("[ai connection health] down : name={}, error={}", connection.connectionName(), e.toErrorType());
            return new AiConnectionHealth(false, System.currentTimeMillis() - startedAtMilliseconds,
                    connection.connectionName() + " · " + toFailureDetail(e), LocalDateTime.now());
        }
    }

    /** 1순위 사용 중 연결 확인 (5분 캐시, 연결 없음도 실패로) */
    public AiConnectionHealth checkTopConnection() {
        AiConnectionHealth cached = cachedTopConnectionHealth;
        if (isFresh(cached)) {
            return cached;
        }
        synchronized (topConnectionHealthLock) {
            cached = cachedTopConnectionHealth;
            if (!isFresh(cached)) {
                List<AiConnectionTarget> callTargets = aiConnectionRegistry.findCallTargets();
                cached = callTargets.isEmpty()
                        ? new AiConnectionHealth(false, 0, "사용 중인 AI 연결 없음", LocalDateTime.now())
                        : check(callTargets.get(0));
                cachedTopConnectionHealth = cached;
            }
            return cached;
        }
    }

    /** 연결 변경 후 1순위 확인 캐시 비움 */
    public void clearTopConnectionHealth() {
        cachedTopConnectionHealth = null;
    }

    private static boolean isFresh(AiConnectionHealth health) {
        return health != null
                && health.checkedAt().isAfter(LocalDateTime.now().minusMinutes(TOP_CONNECTION_HEALTH_CACHE_MINUTES));
    }

    // 실패 원인 문구 (응답 원문은 넣지 않음)
    private static String toFailureDetail(AiProviderException e) {
        Integer statusCode = e.getStatusCode();
        if (statusCode == null) {
            return "응답 없음 (연결·시간 초과)";
        }
        if (statusCode == QUOTA_EXCEEDED_STATUS_CODE) {
            return "한도 초과 (429)";
        }
        if (statusCode == UNAUTHORIZED_STATUS_CODE || statusCode == FORBIDDEN_STATUS_CODE) {
            return "키 무효·권한·결제 확인 필요 (" + statusCode + ")";
        }
        return "응답 오류 (" + statusCode + ")";
    }
}
