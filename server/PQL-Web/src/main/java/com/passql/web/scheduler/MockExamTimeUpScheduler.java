package com.passql.web.scheduler;

import com.passql.submission.service.MockExamAttemptService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * 모의고사 시간 끝 자동 채점 (#866): 앱을 다시 열지 않은 응시도 결과·문항 통계·추이에 들어가게
 * 회원이 목록·시험지·결과를 열 때도 같은 채점을 먼저 하므로 여기는 남은 것만
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class MockExamTimeUpScheduler {

    private final MockExamAttemptService mockExamAttemptService;

    /** 10분마다 마감 지난 응시 채점 */
    @Scheduled(fixedDelay = 600_000)
    public void finalizeExpiredAttempts() {
        int finalizedCount = mockExamAttemptService.finalizeExpiredAttempts();
        if (finalizedCount > 0) {
            log.info("[mock exam] time up attempts graded : count={}", finalizedCount);
        }
    }
}
