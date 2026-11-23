package com.passql.submission.service;

import com.passql.question.event.CuratedChoiceSetReplacedEvent;
import com.passql.submission.entity.MockExamRoundItem;
import com.passql.submission.repository.MockExamRoundItemRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * 회차 문항 세트 재연결: 고정 세트 교체 > 문제를 담은 회차 문항(초안·공개·보관 무관)을 새 세트로 (#1155)
 * 교체 트랜잭션 안 동기 실행 (실패 시 교체도 롤백), 응시 답안(문항 UUID + 보기 키)·제출 기록은 그대로
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class MockExamRoundItemChoiceSetRepointListener {

    private final MockExamRoundItemRepository roundItemRepository;

    @EventListener
    @Transactional
    public void onCuratedChoiceSetReplaced(CuratedChoiceSetReplacedEvent event) {
        UUID newChoiceSetUuid = event.newChoiceSetUuid();
        // 새 세트 외 세트를 가리키는 문항 전부 (이번에 비활성된 세트 + 이전 교체로 이미 비활성된 세트)
        for (MockExamRoundItem roundItem : roundItemRepository.findByQuestionUuid(event.questionUuid())) {
            UUID previousChoiceSetUuid = roundItem.getChoiceSetUuid();
            if (newChoiceSetUuid.equals(previousChoiceSetUuid)) {
                continue;
            }
            roundItem.setChoiceSetUuid(newChoiceSetUuid);
            roundItemRepository.save(roundItem);
            log.info("[mock exam round] choice set repointed : round={}, questionNumber={}, question={}, set {} -> {}, disabledSets={}",
                    roundItem.getMockExamRoundUuid(), roundItem.getQuestionNumber(), event.questionUuid(),
                    previousChoiceSetUuid, newChoiceSetUuid, event.disabledChoiceSetUuids());
        }
    }
}
