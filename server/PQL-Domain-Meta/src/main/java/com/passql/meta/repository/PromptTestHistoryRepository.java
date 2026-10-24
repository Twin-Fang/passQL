package com.passql.meta.repository;

import com.passql.meta.entity.PromptTestHistory;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PromptTestHistoryRepository extends JpaRepository<PromptTestHistory, UUID> {
    List<PromptTestHistory> findByPromptTemplateUuidOrderByCreatedAtDesc(UUID promptTemplateUuid, Pageable pageable);
}
