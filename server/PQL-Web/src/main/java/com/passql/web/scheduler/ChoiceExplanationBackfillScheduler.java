package com.passql.web.scheduler;

import com.passql.application.service.ChoiceExplanationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * 해설 필요한 선택지 세트 백필 (#496, #521): 10분마다 최신 세트 몇 개씩 (해설 없음·낡은 프롬프트 버전·재시도 가능 실패)
 * 한 번에 적게(세트 6개 = Gemini 최대 12회, 세트당 1회 + 위반 시 재시도 1회) 돌려 비용과 스케줄러 점유를 낮춘다.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ChoiceExplanationBackfillScheduler {

    // 실행 1회당 처리할 세트 수
    private static final int SETS_PER_RUN = 6;

    private final ChoiceExplanationService choiceExplanationService;

    /** 서버 기동 5분 뒤부터, 끝난 시점 기준 10분 간격 */
    @Scheduled(initialDelay = 300_000, fixedDelay = 600_000)
    public void backfillMissingExplanations() {
        int createdCount = choiceExplanationService.backfillMissingExplanations(SETS_PER_RUN);
        if (createdCount > 0) {
            log.info("[choice explanation] backfill done : created={}", createdCount);
        }
    }
}
