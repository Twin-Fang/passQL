package com.passql.meta.service;

import com.passql.meta.entity.ServerErrorLog;
import com.passql.meta.repository.ServerErrorLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ServerErrorLogService {

    static final int MAX_URI = 500;
    static final int MAX_DETAIL = 2000;
    public static final int RETENTION_DAYS = 30;

    private final ServerErrorLogRepository repository;

    /**
     * 오류 한 건을 기록한다. 기록 실패(DB 장애 등)가 원래 요청 처리에 번지면 안 되므로 예외를 삼킨다.
     * 바깥 트랜잭션이 롤백 중이어도 남도록 새 트랜잭션에서 쓴다.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void record(String requestId, String memberId, String method, String uri, int status, String detail) {
        try {
            repository.save(ServerErrorLog.of(requestId, memberId, method,
                    truncate(uri, MAX_URI), status, truncate(detail, MAX_DETAIL)));
        } catch (Exception e) {
            log.warn("[server-error-log] 기록 실패: {}", e.getClass().getSimpleName());
        }
    }

    public List<ServerErrorLog> findRecent() {
        return repository.findTop50ByOrderByOccurredAtDesc();
    }

    public long countLast24h() {
        return repository.countByOccurredAtAfter(LocalDateTime.now().minusHours(24));
    }

    @Transactional
    public int purgeExpired() {
        return repository.deleteOlderThan(LocalDateTime.now().minusDays(RETENTION_DAYS));
    }

    static String truncate(String value, int max) {
        if (value == null || value.length() <= max) return value;
        return value.substring(0, max);
    }
}
