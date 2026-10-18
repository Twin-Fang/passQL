package com.passql.application.service;

import com.passql.question.event.ChoiceSetReadyEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

/**
 * 선택지 세트 저장 커밋 후 > 세트 구조화 AI 해설 미리 생성 (#496, #521)
 * 풀이 응답을 늦추지 않게 AI 작업 스레드에서 돌리고, 실패해도 첫 조회·백필이 다시 채운다.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ChoiceExplanationPregenerationListener {

    private final ChoiceExplanationService choiceExplanationService;

    @Async("aiTaskExecutor")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
    public void onChoiceSetReady(ChoiceSetReadyEvent event) {
        try {
            choiceExplanationService.pregenerateExplanation(event.choiceSetUuid());
        } catch (Exception e) {
            // 미리 생성은 보조 경로라 실패를 삼키고 기록만 (성공·실패 공통으로 풀이에는 영향 없음)
            log.warn("[choice explanation] pregenerate failed : choiceSet={}", event.choiceSetUuid(), e);
        }
    }
}
