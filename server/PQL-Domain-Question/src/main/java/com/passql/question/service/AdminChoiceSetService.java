package com.passql.question.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

/**
 * 관리자 선택지 세트: 이력 조회, 항목 조회, 비활성화, 재사용 풀 승격
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminChoiceSetService {

    private final QuestionChoiceSetRepository choiceSetRepository;
    private final QuestionChoiceSetItemRepository choiceSetItemRepository;

    public Page<QuestionChoiceSet> getChoiceSets(Pageable pageable) {
        return choiceSetRepository.findAll(pageable);
    }

    public QuestionChoiceSet getChoiceSet(UUID choiceSetUuid) {
        return choiceSetRepository.findById(choiceSetUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.CHOICE_SET_NOT_FOUND));
    }

    public List<QuestionChoiceSetItem> getChoiceSetItems(UUID choiceSetUuid) {
        return choiceSetItemRepository.findByChoiceSetUuidOrderBySortOrderAsc(choiceSetUuid);
    }

    @Transactional
    public void disableChoiceSet(UUID choiceSetUuid) {
        QuestionChoiceSet choiceSet = getChoiceSet(choiceSetUuid);
        choiceSet.setStatus(ChoiceSetStatus.DISABLED);
        choiceSetRepository.save(choiceSet);
    }

    /** 관리자 큐레이션 출처로 바꾸고 재사용 가능 표시 */
    @Transactional
    public void promoteChoiceSetToReusable(UUID choiceSetUuid) {
        QuestionChoiceSet choiceSet = getChoiceSet(choiceSetUuid);
        choiceSet.setSource(ChoiceSetSource.ADMIN_CURATED);
        choiceSet.setIsReusable(true);
        choiceSetRepository.save(choiceSet);
    }
}
