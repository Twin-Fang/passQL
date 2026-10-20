package com.passql.ai.entity;

import com.passql.ai.constant.AiCallSource;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
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
 * AI 호출 1건: 출처, 경로, 모델, 성공 여부, 지연(ms), 실패 종류, 토큰 수 — 대시보드·모니터링·비용 집계용, 400일 보관 (#474, #557)
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

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private AiCallSource callSource;

    // AI 서버 경로 (예: /api/ai/generate-choice-set) 또는 직접 호출 기능 (예: gemini:chat)
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

    // 호출 모델 (예: gemini-2.5-flash-lite, 모르면 null)
    @Column(length = 100)
    private String modelName;

    // 입력 토큰 수 (모르면 null)
    private Integer promptTokenCount;

    // 출력 토큰 수, thinking 포함 (모르면 null)
    private Integer completionTokenCount;

    public static AiCallLog of(AiCallSource callSource, String endpointPath, String modelName, boolean isSuccess,
                               long latencyMilliseconds, String errorType,
                               Integer promptTokenCount, Integer completionTokenCount) {
        AiCallLog callLog = new AiCallLog();
        callLog.callSource = callSource;
        callLog.endpointPath = endpointPath;
        callLog.modelName = modelName;
        callLog.isSuccess = isSuccess;
        callLog.latencyMilliseconds = latencyMilliseconds;
        callLog.errorType = errorType;
        callLog.promptTokenCount = promptTokenCount;
        callLog.completionTokenCount = completionTokenCount;
        callLog.calledAt = LocalDateTime.now();
        return callLog;
    }
}
