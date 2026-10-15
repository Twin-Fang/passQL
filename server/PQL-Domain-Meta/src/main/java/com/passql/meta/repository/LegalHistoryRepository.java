package com.passql.meta.repository;

import com.passql.meta.constant.LegalType;
import com.passql.meta.entity.LegalHistory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface LegalHistoryRepository extends JpaRepository<LegalHistory, UUID> {

    List<LegalHistory> findTop20ByTypeOrderByArchivedAtDesc(LegalType type);
}
