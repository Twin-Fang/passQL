package com.passql.ai.repository;

import com.passql.ai.entity.AiErrorExplanation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface AiErrorExplanationRepository extends JpaRepository<AiErrorExplanation, UUID> {

    Optional<AiErrorExplanation> findByQuestionUuidAndSqlHashAndErrorHash(
            UUID questionUuid, String sqlHash, String errorHash);
}
