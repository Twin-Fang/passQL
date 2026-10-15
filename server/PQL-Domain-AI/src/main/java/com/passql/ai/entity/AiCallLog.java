package com.passql.ai.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * AI 서버 호출 1건: 경로, 성공 여부, 지연(ms), 실패 종류 — 대시보드·모니터링 집계용, 30일 보관 (#474)
 */
@Entity
@Table(
    name = "ai_call_log",
    indexes = @Index(name = "idx_ai_call_log_called_at", columnList = "called_at")
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AiCallLog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID aiCallLogUuid;

    // AI 서버 경로 (예: /api/ai/generate-choice-set)
    @Column(nullable = false, length = 100)
    private String endpointPath;

    @Column(nullable = false)
    private Boolean isSuccess;

    @Column(nullable = false)
    private Long latencyMilliseconds;

    // 실패 예외 클래스 이름 또는 HTTP 상태 (성공이면 null)
    @Column(length = 100)
    private String errorType;

    @Column(nullable = false)
    private LocalDateTime calledAt;

    public static AiCallLog of(String endpointPath, boolean isSuccess, long latencyMilliseconds, String errorType) {
        AiCallLog callLog = new AiCallLog();
        callLog.endpointPath = endpointPath;
        callLog.isSuccess = isSuccess;
        callLog.latencyMilliseconds = latencyMilliseconds;
        callLog.errorType = errorType;
        callLog.calledAt = LocalDateTime.now();
        return callLog;
    }
}
