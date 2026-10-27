package com.passql.meta.repository;

import com.passql.meta.entity.ConceptCheckChoice;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface ConceptCheckChoiceRepository extends JpaRepository<ConceptCheckChoice, UUID> {

    List<ConceptCheckChoice> findByConceptCheckQuestionUuidInOrderBySortOrderAsc(Collection<UUID> conceptCheckQuestionUuids);
}
