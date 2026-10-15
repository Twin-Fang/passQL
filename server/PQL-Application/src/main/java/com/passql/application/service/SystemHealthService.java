package com.passql.application.service;

import com.passql.ai.client.AiGatewayClient;
import com.passql.ai.dto.ComponentHealth;
import com.passql.application.dto.CircuitBreakerStatus;
import com.passql.application.dto.SystemHealthSnapshot;
import io.github.resilience4j.circuitbreaker.CircuitBreaker;
import io.github.resilience4j.circuitbreaker.CircuitBreakerRegistry;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.connection.RedisConnection;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * 모니터링 상태 수집 (#475): AI 서버 /health, Qdrant(AI 서버 경유), Redis PING, resilience4j 서킷
 * 구성 요소 3개 동시 확인 (각 3초 제한, 하나가 느려도 화면이 오래 묶이지 않게)
 */
@Service
@RequiredArgsConstructor
public class SystemHealthService {

    private static final String REDIS_COMPONENT_NAME = "Redis";
    private static final String REDIS_PONG = "PONG";

    private final AiGatewayClient aiGatewayClient;
    private final StringRedisTemplate stringRedisTemplate;
    private final CircuitBreakerRegistry circuitBreakerRegistry;

    public SystemHealthSnapshot collect() {
        try (ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor()) {
            CompletableFuture<ComponentHealth> aiServer = CompletableFuture.supplyAsync(aiGatewayClient::checkAiServerHealth, executor);
            CompletableFuture<ComponentHealth> qdrant = CompletableFuture.supplyAsync(aiGatewayClient::checkQdrantThroughAiServer, executor);
            CompletableFuture<ComponentHealth> redis = CompletableFuture.supplyAsync(this::checkRedis, executor);
            List<ComponentHealth> components = List.of(aiServer.join(), qdrant.join(), redis.join());
            return new SystemHealthSnapshot(components, collectCircuitBreakers());
        }
    }

    /** Redis PING (설정 캐시·리프레시 토큰 저장소) */
    private ComponentHealth checkRedis() {
        long startedAtMilliseconds = System.currentTimeMillis();
        try {
            String pong = stringRedisTemplate.execute(RedisConnection::ping, true);
            long latency = System.currentTimeMillis() - startedAtMilliseconds;
            return REDIS_PONG.equalsIgnoreCase(pong)
                    ? ComponentHealth.up(REDIS_COMPONENT_NAME, latency, "PING " + pong)
                    : ComponentHealth.down(REDIS_COMPONENT_NAME, latency, "PING 응답 " + pong);
        } catch (Exception e) {
            return ComponentHealth.down(REDIS_COMPONENT_NAME, System.currentTimeMillis() - startedAtMilliseconds,
                    e.getClass().getSimpleName());
        }
    }

    /** 등록된 서킷 전체 (이름순) */
    private List<CircuitBreakerStatus> collectCircuitBreakers() {
        return circuitBreakerRegistry.getAllCircuitBreakers().stream()
                .sorted(Comparator.comparing(CircuitBreaker::getName))
                .map(this::toCircuitBreakerStatus)
                .toList();
    }

    private CircuitBreakerStatus toCircuitBreakerStatus(CircuitBreaker circuitBreaker) {
        CircuitBreaker.Metrics metrics = circuitBreaker.getMetrics();
        return new CircuitBreakerStatus(
                circuitBreaker.getName(),
                circuitBreaker.getState().name(),
                metrics.getFailureRate(),
                metrics.getNumberOfBufferedCalls(),
                metrics.getNumberOfFailedCalls(),
                metrics.getNumberOfNotPermittedCalls());
    }
}
