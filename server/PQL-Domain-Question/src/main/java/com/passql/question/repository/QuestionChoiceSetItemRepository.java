package com.passql.question.repository;

import com.passql.question.entity.QuestionChoiceSetItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface QuestionChoiceSetItemRepository extends JpaRepository<QuestionChoiceSetItem, UUID> {

    List<QuestionChoiceSetItem> findByChoiceSetUuidOrderBySortOrderAsc(UUID choiceSetUuid);

    /** 여러 세트 보기 한 번에 (모의고사 시험지 50문항, #866) */
    List<QuestionChoiceSetItem> findByChoiceSetUuidInOrderBySortOrderAsc(Collection<UUID> choiceSetUuids);

    Optional<QuestionChoiceSetItem> findByChoiceSetUuidAndChoiceKey(UUID choiceSetUuid, String choiceKey);

    @Modifying
    @Transactional
    void deleteByChoiceSetUuidIn(List<UUID> choiceSetUuids);
}
