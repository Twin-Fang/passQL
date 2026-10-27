package com.passql.ai.dto;

/**
 * 시도 1회: 연결 + 그 연결로 보낼 모델
 */
public record AiCallAttempt(AiConnectionTarget connection, String model) {
}
