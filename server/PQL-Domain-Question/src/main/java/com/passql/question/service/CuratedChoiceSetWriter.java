package com.passql.question.service;

import com.passql.question.constant.ChoiceKind;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.dto.CuratedChoiceDto;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

/**
 * 관리자 고정 보기 세트 저장 공통: 기존 고정 OK 세트 비활성 > 새 ADMIN_CURATED 세트 + 보기 저장 (#511)
 * 해설은 검증 근거(rationale)를 그대로 저장 > AI 해설 미리 생성·백필 대상 아님 (Oracle 문제 AI 해설 오답 방지)
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class CuratedChoiceSetWriter {

    private final QuestionChoiceSetRepository choiceSetRepository;
    private final QuestionChoiceSetItemRepository choiceSetItemRepository;

    /** 고정 세트 교체: 기존 고정 세트 비활성 > 새 세트 저장 > 보기 저장 (순번 1..N) */
    @Transactional
    public QuestionChoiceSet replaceCuratedSet(UUID questionUuid, List<CuratedChoiceDto> choices) {
        disableActiveCuratedSets(questionUuid);
        QuestionChoiceSet curatedSet = choiceSetRepository.saveAndFlush(QuestionChoiceSet.builder()
                .questionUuid(questionUuid)
                .source(ChoiceSetSource.ADMIN_CURATED)
                .status(ChoiceSetStatus.OK)
                .generationAttempts(1)
                .sandboxValidationPassed(false)
                .isReusable(true)
                .build());
        saveChoiceItems(curatedSet.getChoiceSetUuid(), choices);
        log.info("[curated choice set] replaced : questionUuid={}, setUuid={}, choices={}",
                questionUuid, curatedSet.getChoiceSetUuid(), choices.size());
        return curatedSet;
    }

    // 기존 고정 OK 세트 비활성 (AI 세트는 유지, 풀이 조회가 고정 세트 우선이라 영향 없음)
    private void disableActiveCuratedSets(UUID questionUuid) {
        for (QuestionChoiceSet choiceSet : choiceSetRepository.findByQuestionUuidOrderByCreatedAtDesc(questionUuid)) {
            boolean isActiveCuratedSet = choiceSet.getSource() != null && choiceSet.getSource().isCurated()
                    && choiceSet.getStatus() == ChoiceSetStatus.OK;
            if (isActiveCuratedSet) {
                choiceSet.setStatus(ChoiceSetStatus.DISABLED);
                choiceSetRepository.save(choiceSet);
            }
        }
    }

    private void saveChoiceItems(UUID choiceSetUuid, List<CuratedChoiceDto> choices) {
        for (int index = 0; index < choices.size(); index++) {
            CuratedChoiceDto choice = choices.get(index);
            choiceSetItemRepository.save(QuestionChoiceSetItem.builder()
                    .choiceSetUuid(choiceSetUuid)
                    .choiceKey(choice.choiceKey())
                    .sortOrder(index + 1)
                    .kind(toChoiceKind(choice.kind()))
                    .body(choice.body())
                    .isCorrect(Boolean.TRUE.equals(choice.isCorrect()))
                    .rationale(choice.rationale())
                    .explanation(choice.rationale())
                    .build());
        }
    }

    /** 보기 종류 문자열 > ChoiceKind (SQL 만 SQL, 그 외·빈 값 TEXT) */
    private ChoiceKind toChoiceKind(String kind) {
        return "SQL".equalsIgnoreCase(kind) ? ChoiceKind.SQL : ChoiceKind.TEXT;
    }
}
