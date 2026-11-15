package com.passql.application.concept;

import com.passql.meta.entity.ConceptTag;
import com.passql.meta.entity.Topic;

import java.util.List;
import java.util.Objects;
import java.util.UUID;

/**
 * 활성 단원 순서 + 회원에게 보이는 개념 묶음 (개념 학습·OX 퀴즈 공용, 단원 순서가 무료 단원 판정 기준)
 */
public record ConceptCatalog(List<Topic> topics, List<ConceptTag> visibleConcepts) {

    public List<ConceptTag> conceptsOf(UUID topicUuid) {
        return visibleConcepts.stream()
            .filter(concept -> Objects.equals(concept.getTopicUuid(), topicUuid))
            .toList();
    }

    public List<UUID> visibleConceptUuids() {
        return visibleConcepts.stream().map(ConceptTag::getConceptTagUuid).toList();
    }

    public boolean isVisible(UUID conceptUuid) {
        return visibleConcepts.stream().anyMatch(concept -> concept.getConceptTagUuid().equals(conceptUuid));
    }

    /** 단원 순서 (0부터), 없으면 -1 */
    public int orderIndexOf(UUID topicUuid) {
        for (int index = 0; index < topics.size(); index++) {
            if (topics.get(index).getTopicUuid().equals(topicUuid)) {
                return index;
            }
        }
        return -1;
    }
}
