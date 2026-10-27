package com.passql.meta.repository;

import com.passql.meta.entity.ConceptCheckQuestion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface ConceptCheckQuestionRepository extends JpaRepository<ConceptCheckQuestion, UUID> {

    List<ConceptCheckQuestion> findByConceptTagUuidOrderBySortOrderAsc(UUID conceptTagUuid);

    List<ConceptCheckQuestion> findByConceptTagUuidIn(Collection<UUID> conceptTagUuids);

    long countByConceptTagUuid(UUID conceptTagUuid);

    void deleteByConceptTagUuid(UUID conceptTagUuid);
}
