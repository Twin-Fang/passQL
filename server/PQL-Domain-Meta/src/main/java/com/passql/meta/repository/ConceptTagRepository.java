package com.passql.meta.repository;

import com.passql.meta.entity.ConceptTag;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ConceptTagRepository extends JpaRepository<ConceptTag, UUID> {
    Optional<ConceptTag> findByTagKey(String tagKey);
    List<ConceptTag> findByIsActiveTrueOrderBySortOrderAsc();

    List<ConceptTag> findByTopicUuidInAndIsActiveTrueOrderBySortOrderAsc(Collection<UUID> topicUuids);
    boolean existsByTagKey(String tagKey);
}
