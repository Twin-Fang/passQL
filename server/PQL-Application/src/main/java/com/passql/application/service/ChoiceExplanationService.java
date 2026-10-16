package com.passql.application.service;

import com.passql.ai.dto.AiResult;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import com.passql.question.repository.QuestionRepository;
import com.passql.question.service.QuestionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Objects;
import java.util.UUID;

/**
 * 선택지별 AI 해설 영구 저장 (#496): 저장된 해설 재사용, 없거나 낡으면 생성 후 저장, 세트 단위 미리 생성
 * Gemini 호출은 DB 트랜잭션 밖에서 하고 저장만 짧게 한다.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ChoiceExplanationService {

    private final QuestionRepository questionRepository;
    private final QuestionChoiceSetRepository choiceSetRepository;
    private final QuestionChoiceSetItemRepository choiceSetItemRepository;
    private final AiExplanationGenerator explanationGenerator;

    // 고정 세트 해설 프롬프트 버전 표시값 (AI 생성 아님)
    private static final int CURATED_EXPLANATION_PROMPT_VERSION = 0;

    /**
     * 선택지 해설 1건: 저장본(활성 프롬프트 버전) 있으면 그대로 > 없으면 생성·저장
     * 세트에 없는 선택지 키 > INVALID_INPUT_VALUE
     */
    public AiResult getOrCreateExplanation(Question question, UUID choiceSetUuid, String choiceKey) {
        List<QuestionChoiceSetItem> items = choiceSetItemRepository.findByChoiceSetUuidOrderBySortOrderAsc(choiceSetUuid);
        QuestionChoiceSetItem selectedItem = items.stream()
                .filter(item -> item.getChoiceKey().equals(choiceKey))
                .findFirst()
                .orElseThrow(() -> new CustomException(ErrorCode.INVALID_INPUT_VALUE));

        // 고정 세트는 검증 근거 해설 그대로 (AI 생성·덮어쓰기 없음, #511)
        if (isCuratedChoiceSet(question, choiceSetUuid)) {
            String storedExplanation = selectedItem.getExplanation() != null ? selectedItem.getExplanation() : selectedItem.getRationale();
            return new AiResult(storedExplanation, CURATED_EXPLANATION_PROMPT_VERSION);
        }
        Integer activePromptVersion = explanationGenerator.activeChoicePromptVersion();
        if (hasCurrentExplanation(selectedItem, activePromptVersion)) {
            return new AiResult(selectedItem.getExplanation(), selectedItem.getExplanationPromptVersion());
        }
        AiExplanationGenerator.GeneratedExplanation generated =
                explanationGenerator.generateChoiceExplanation(question, items, choiceKey);
        saveExplanation(selectedItem, generated);
        return new AiResult(generated.text(), generated.promptVersion());
    }

    /**
     * 세트의 선택지 해설 미리 생성: 저장본 없거나 낡은 선택지만, 순서대로 (AI 실패 시 남은 것은 다음 기회로)
     * @return 새로 만든 해설 수
     */
    public int pregenerateExplanations(UUID choiceSetUuid) {
        QuestionChoiceSet choiceSet = choiceSetRepository.findById(choiceSetUuid).orElse(null);
        if (choiceSet == null) return 0;
        Question question = questionRepository.findById(choiceSet.getQuestionUuid()).orElse(null);
        if (question == null) return 0;
        if (QuestionService.isCuratedChoiceSet(question, choiceSet)) return 0;

        List<QuestionChoiceSetItem> items = choiceSetItemRepository.findByChoiceSetUuidOrderBySortOrderAsc(choiceSetUuid);
        Integer activePromptVersion = explanationGenerator.activeChoicePromptVersion();
        int createdCount = 0;
        for (QuestionChoiceSetItem item : items) {
            if (hasCurrentExplanation(item, activePromptVersion)) continue;
            try {
                saveExplanation(item, explanationGenerator.generateChoiceExplanation(question, items, item.getChoiceKey()));
                createdCount++;
            } catch (CustomException e) {
                log.warn("[choice explanation] pregenerate stopped : choiceSet={} key={} reason={}",
                        choiceSetUuid, item.getChoiceKey(), e.getErrorCode());
                break;
            }
        }
        log.info("[choice explanation] pregenerated : choiceSet={} created={}", choiceSetUuid, createdCount);
        return createdCount;
    }

    /**
     * 해설 없는 기존 세트 백필: 최신 세트부터 setLimit 개 (세트마다 실패해도 다음 세트 계속)
     * @return 새로 만든 해설 수
     */
    public int backfillMissingExplanations(int setLimit) {
        List<UUID> choiceSetUuids = choiceSetRepository.findChoiceSetUuidsMissingExplanation(PageRequest.of(0, setLimit));
        int createdCount = 0;
        for (UUID choiceSetUuid : choiceSetUuids) {
            try {
                createdCount += pregenerateExplanations(choiceSetUuid);
            } catch (Exception e) {
                log.warn("[choice explanation] backfill failed : choiceSet={}", choiceSetUuid, e);
            }
        }
        return createdCount;
    }

    /** 고정 출제 세트 여부 (세트 조회 실패 시 false) */
    private boolean isCuratedChoiceSet(Question question, UUID choiceSetUuid) {
        return choiceSetRepository.findById(choiceSetUuid)
                .map(choiceSet -> QuestionService.isCuratedChoiceSet(question, choiceSet))
                .orElse(false);
    }

    /** 저장된 해설이 있고 활성 프롬프트 버전으로 만든 것인지 */
    private boolean hasCurrentExplanation(QuestionChoiceSetItem item, Integer activePromptVersion) {
        return item.getExplanation() != null && !item.getExplanation().isBlank()
                && Objects.equals(item.getExplanationPromptVersion(), activePromptVersion);
    }

    private void saveExplanation(QuestionChoiceSetItem item, AiExplanationGenerator.GeneratedExplanation generated) {
        item.setExplanation(generated.text());
        item.setExplanationPromptVersion(generated.promptVersion());
        choiceSetItemRepository.save(item);
    }
}
