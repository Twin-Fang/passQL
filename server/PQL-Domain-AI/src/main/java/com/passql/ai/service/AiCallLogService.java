package com.passql.ai.service;

import com.passql.ai.dto.AiStats;
import com.passql.ai.entity.AiCallLog;
import com.passql.ai.repository.AiCallLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * AI 서버 호출 기록·집계 (#474): AiGatewayClient 호출 지점 1곳에서 기록, 대시보드·모니터링이 기간 집계
 * 기록은 별도 단일 스레드에서 (요청 커넥션 점유·실패 전파 없음, 과부하 시 버림)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AiCallLogService {

    // 기록 전용 실행기 이름 (PQL-Web AsyncConfig 가 같은 이름으로 등록)
    public static final String RECORD_EXECUTOR_NAME = "aiCallLogExecutor";
    // 보관 기간 (일)
    public static final int RETENTION_DAYS = 30;

    private final AiCallLogRepository aiCallLogRepository;

    @Async(RECORD_EXECUTOR_NAME)
    @Transactional
    public void record(String endpointPath, boolean isSuccess, long latencyMilliseconds, String errorType) {
        try {
            aiCallLogRepository.save(AiCallLog.of(endpointPath, isSuccess, latencyMilliseconds, errorType));
        } catch (Exception e) {
            log.warn("[ai call log] record failed : {}", e.getClass().getSimpleName());
        }
    }

    /** since 이후 호출 집계 */
    public AiStats getStatsSince(LocalDateTime since) {
        List<Object[]> rows = aiCallLogRepository.aggregateSince(since);
        if (rows.isEmpty() || rows.get(0)[0] == null) {
            return AiStats.empty();
        }
        Object[] row = rows.get(0);
        long totalCallCount = toLong(row[0]);
        long successCount = toLong(row[1]);
        double averageLatency = row[2] == null ? 0 : ((Number) row[2]).doubleValue();
        return new AiStats(totalCallCount, successCount, totalCallCount - successCount, averageLatency, toLong(row[3]));
    }

    /** 최근 24시간 집계 */
    public AiStats getStatsLast24Hours() {
        return getStatsSince(LocalDateTime.now().minusHours(24));
    }

    @Transactional
    public int purgeExpired() {
        return aiCallLogRepository.deleteOlderThan(LocalDateTime.now().minusDays(RETENTION_DAYS));
    }

    private static long toLong(Object value) {
        return value == null ? 0 : ((Number) value).longValue();
    }
}
