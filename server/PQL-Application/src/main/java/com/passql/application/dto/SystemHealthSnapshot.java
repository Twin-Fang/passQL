package com.passql.application.dto;

import com.passql.ai.dto.ComponentHealth;

import java.util.List;

/** 모니터링 상태 카드 묶음 (#475): 외부 구성 요소 3종(AI 서버, Qdrant, Redis) + 서킷 상태 */
public record SystemHealthSnapshot(
        List<ComponentHealth> components,
        List<CircuitBreakerStatus> circuitBreakers
) {}
