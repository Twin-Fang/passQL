package com.passql.meta.repository;

import com.passql.meta.entity.PromptTemplateHistory;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PromptTemplateHistoryRepository extends JpaRepository<PromptTemplateHistory, UUID> {
    List<PromptTemplateHistory> findByPromptTemplateUuidOrderByCreatedAtDesc(UUID promptTemplateUuid, Pageable pageable);
}
