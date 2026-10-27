package com.passql.application.service;

import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.member.constant.ChoiceGenerationMode;
import com.passql.member.service.MemberService;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.event.ChoiceSetReadyEvent;
import com.passql.question.repository.QuestionChoiceSetRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.UUID;

/**
 * 선택지 세트 저장 커밋 후 > 세트 구조화 AI 해설 미리 생성 (#496, #521)
 * 대상: 연습 모드로 만든 공용 세트만. 실전 모드 1인용 세트는 처음 열 때 생성 (#699)
 * 풀이 응답을 늦추지 않게 AI 작업 스레드에서 돌리고, 실패해도 첫 조회·백필이 다시 채운다.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ChoiceExplanationPregenerationListener {

    private final ChoiceExplanationService choiceExplanationService;
    private final QuestionChoiceSetRepository choiceSetRepository;
    private final MemberService memberService;
    private final FeatureAccessPolicy featureAccessPolicy;

    @Async("aiTaskExecutor")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
    public void onChoiceSetReady(ChoiceSetReadyEvent event) {
        try {
            if (isPersonalRealModeSet(event.choiceSetUuid())) {
                log.debug("[choice explanation] pregenerate skipped : real mode set, choiceSet={}", event.choiceSetUuid());
                return;
            }
            choiceExplanationService.pregenerateExplanation(event.choiceSetUuid());
        } catch (Exception e) {
            // 미리 생성은 보조 경로라 실패를 삼키고 기록만 (성공·실패 공통으로 풀이에는 영향 없음)
            log.warn("[choice explanation] pregenerate failed : choiceSet={}", event.choiceSetUuid(), e);
        }
    }

    /** 실전 모드 회원이 연 문제마다 새로 만든 1인용 세트인지 (해설을 안 열 수도 있어 미리 만들지 않음) */
    private boolean isPersonalRealModeSet(UUID choiceSetUuid) {
        UUID ownerMemberUuid = choiceSetRepository.findById(choiceSetUuid)
                .map(QuestionChoiceSet::getGeneratedForMemberUuid)
                .orElse(null);
        if (ownerMemberUuid == null) return false;
        ChoiceGenerationMode effectiveMode = featureAccessPolicy.resolveEffectiveChoiceGenerationMode(
                ownerMemberUuid, memberService.getChoiceGenerationMode(ownerMemberUuid));
        return effectiveMode == ChoiceGenerationMode.REAL;
    }
}
