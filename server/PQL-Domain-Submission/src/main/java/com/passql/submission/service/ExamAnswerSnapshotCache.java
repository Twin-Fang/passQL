package com.passql.submission.service;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import com.passql.submission.entity.ExamAnswerRound;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.time.Duration;
import java.util.UUID;

/**
 * 회차 집계 인메모리 캐시 (서버 1대 기준): 회차 UUID > 집계, 60초 뒤 다시 계산
 * 같은 회차 동시 요청은 1번만 계산 (Caffeine get 원자성), 관리자 변경은 커밋 뒤 비움
 */
@Component
@RequiredArgsConstructor
public class ExamAnswerSnapshotCache {

    // 득표 집계 보관 시간 (초)
    private static final Duration SNAPSHOT_TIME_TO_LIVE = Duration.ofSeconds(60);
    // 동시에 보관할 회차 수
    private static final long MAXIMUM_CACHED_ROUND_COUNT = 50;

    private final ExamAnswerSnapshotLoader examAnswerSnapshotLoader;

    private final Cache<UUID, ExamAnswerRoundSnapshot> snapshotByRoundUuid = Caffeine.newBuilder()
            .maximumSize(MAXIMUM_CACHED_ROUND_COUNT)
            .expireAfterWrite(SNAPSHOT_TIME_TO_LIVE)
            .build();

    public ExamAnswerRoundSnapshot get(ExamAnswerRound round) {
        return snapshotByRoundUuid.get(round.getExamAnswerRoundUuid(), ignored -> examAnswerSnapshotLoader.load(round));
    }

    /** 회차 집계 비우기 (트랜잭션 안이면 커밋 뒤, 밖이면 즉시) */
    public void evictAfterCommit(UUID roundUuid) {
        if (!TransactionSynchronizationManager.isSynchronizationActive()) {
            snapshotByRoundUuid.invalidate(roundUuid);
            return;
        }
        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
            @Override
            public void afterCommit() {
                snapshotByRoundUuid.invalidate(roundUuid);
            }
        });
    }
}
