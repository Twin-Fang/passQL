package com.passql.question.service;

import com.passql.question.entity.DailyChallenge;
import com.passql.question.repository.DailyChallengeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * 폴백 데일리 챌린지 저장 전용: 날짜 1개 배정을 독립 트랜잭션 하나로 저장
 * 중복(다른 인스턴스 선저장) 시 이 트랜잭션만 전부 롤백 > 호출부가 예외로 판단
 */
@Component
@RequiredArgsConstructor
public class DailyChallengeFallbackWriter {

    private final DailyChallengeRepository dailyChallengeRepository;

    /** 문제 목록 > 정렬 순서대로 저장 (중복 키면 DataIntegrityViolationException, 부분 저장 없음) */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void saveInOrder(LocalDate challengeDate, List<UUID> questionUuids) {
        for (int sortOrder = 0; sortOrder < questionUuids.size(); sortOrder++) {
            dailyChallengeRepository.saveAndFlush(
                    DailyChallenge.builder()
                            .challengeDate(challengeDate)
                            .sortOrder(sortOrder)
                            .questionUuid(questionUuids.get(sortOrder))
                            .build());
        }
    }
}
