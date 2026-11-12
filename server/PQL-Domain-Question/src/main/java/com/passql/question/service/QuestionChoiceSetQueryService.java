package com.passql.question.service;

import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.dto.ChoiceSetGenerateResponse;
import com.passql.question.dto.CuratedChoiceDto;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

/**
 * 선택지 세트 조회: 고정 세트 판정, 내보내기용 고정 보기, 풀이용 세트 응답(고정 세트는 순서 섞기)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class QuestionChoiceSetQueryService {

    private final QuestionChoiceSetRepository choiceSetRepository;
    private final QuestionChoiceSetItemRepository choiceSetItemRepository;
    private final QuestionService questionService;

    /** 고정 출제 세트 여부: 문제 정책 CURATED_ONLY + 세트 출처 고정 (#511) */
    public static boolean isCuratedChoiceSet(Question question, QuestionChoiceSet choiceSet) {
        return question != null && question.getChoiceSetPolicy() == ChoiceSetPolicy.CURATED_ONLY
                && choiceSet.getSource() != null && choiceSet.getSource().isCurated();
    }

    /** 내보내기용 고정 보기: 최신 고정 OK 세트 > 보기 목록 (없으면 null, #511) */
    public List<CuratedChoiceDto> findActiveCuratedChoices(UUID questionUuid) {
        return choiceSetRepository
                .findFirstByQuestionUuidAndStatusAndSourceInOrderByCreatedAtDesc(
                        questionUuid, ChoiceSetStatus.OK, ChoiceSetSource.CURATED_SOURCES)
                .map(choiceSet -> choiceSetItemRepository.findByChoiceSetUuidOrderBySortOrderAsc(choiceSet.getChoiceSetUuid())
                        .stream()
                        .map(item -> new CuratedChoiceDto(item.getChoiceKey(), item.getKind().name(), item.getBody(),
                                item.getIsCorrect(), item.getRationale()))
                        .toList())
                .orElse(null);
    }

    /** 풀이용 선택지 세트 > 응답 (정답 여부·해설 제외) */
    public ChoiceSetGenerateResponse getChoiceSetForSolving(UUID choiceSetUuid) {
        List<ChoiceSetGenerateResponse.ChoiceItem> choiceItems = findChoiceItemsForSolving(choiceSetUuid);
        // 고정 세트는 응답마다 표시 순서 섞기 (#511)
        boolean isCuratedSet = choiceSetRepository.findById(choiceSetUuid)
                .map(choiceSet -> isCuratedChoiceSet(questionService.getQuestionEntityOrNull(choiceSet.getQuestionUuid()), choiceSet))
                .orElse(false);
        if (isCuratedSet) {
            choiceItems = ChoiceOrderShuffler.shuffle(choiceItems, ChoiceSetGenerateResponse.ChoiceItem::body, (item, sortOrder) -> new ChoiceSetGenerateResponse.ChoiceItem(
                    item.key(), item.kind(), item.body(), sortOrder));
        }
        return new ChoiceSetGenerateResponse(choiceSetUuid, choiceItems);
    }

    private List<ChoiceSetGenerateResponse.ChoiceItem> findChoiceItemsForSolving(UUID choiceSetUuid) {
        return choiceSetItemRepository
                .findByChoiceSetUuidOrderBySortOrderAsc(choiceSetUuid)
                .stream()
                .map(item -> new ChoiceSetGenerateResponse.ChoiceItem(
                        item.getChoiceKey(),
                        item.getKind().name(),
                        item.getBody(),
                        item.getSortOrder()))
                .toList();
    }
}
