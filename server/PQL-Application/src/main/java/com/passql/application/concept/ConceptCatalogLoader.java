package com.passql.application.concept;

import com.passql.meta.constant.ConceptPublishStatus;
import com.passql.meta.entity.ConceptTag;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.ConceptTagRepository;
import com.passql.meta.repository.TopicRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.UUID;

/**
 * 개념 목록 조회: 활성 단원(정렬) + 회원에게 보이는 개념 (초안은 미리보기 회원만)
 */
@Component
@RequiredArgsConstructor
public class ConceptCatalogLoader {

    private final TopicRepository topicRepository;
    private final ConceptTagRepository conceptTagRepository;
    private final ConceptAvailabilityPolicy availabilityPolicy;

    public ConceptCatalog load(UUID memberUuid) {
        List<Topic> topics = topicRepository.findByIsActiveTrueOrderBySortOrderAsc();
        List<UUID> topicUuids = topics.stream().map(Topic::getTopicUuid).toList();
        boolean canSeeDrafts = availabilityPolicy.canSeeDrafts(memberUuid);
        List<ConceptTag> visibleConcepts = topicUuids.isEmpty()
            ? List.of()
            : conceptTagRepository.findByTopicUuidInAndIsActiveTrueOrderBySortOrderAsc(topicUuids).stream()
                .filter(concept -> canSeeDrafts || concept.getPublishStatus() == ConceptPublishStatus.PUBLISHED)
                .toList();
        return new ConceptCatalog(topics, visibleConcepts);
    }
}
