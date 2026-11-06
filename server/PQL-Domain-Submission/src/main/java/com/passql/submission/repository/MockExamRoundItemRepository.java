package com.passql.submission.repository;

import com.passql.submission.entity.MockExamRoundItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface MockExamRoundItemRepository extends JpaRepository<MockExamRoundItem, UUID> {

    List<MockExamRoundItem> findByMockExamRoundUuidOrderByQuestionNumberAsc(UUID mockExamRoundUuid);

    List<MockExamRoundItem> findByMockExamRoundUuidIn(Collection<UUID> mockExamRoundUuids);

    long countByMockExamRoundUuid(UUID mockExamRoundUuid);

    @Modifying
    @Query("DELETE FROM MockExamRoundItem i WHERE i.mockExamRoundUuid = :mockExamRoundUuid")
    void deleteByMockExamRoundUuid(@Param("mockExamRoundUuid") UUID mockExamRoundUuid);
}
