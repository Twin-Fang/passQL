package com.passql.submission.repository;

import com.passql.submission.dto.mockexam.MockExamRoundDifficultyProjection;
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

    /** 회차별 문항 평균 난이도 (문제 난이도 없는 문항은 평균에서 빠짐) */
    @Query("SELECT new com.passql.submission.dto.mockexam.MockExamRoundDifficultyProjection(i.mockExamRoundUuid, AVG(q.difficulty))"
        + " FROM MockExamRoundItem i, com.passql.question.entity.Question q"
        + " WHERE q.questionUuid = i.questionUuid AND i.mockExamRoundUuid IN :roundUuids"
        + " GROUP BY i.mockExamRoundUuid")
    List<MockExamRoundDifficultyProjection> findAverageDifficultyByRoundUuidIn(@Param("roundUuids") Collection<UUID> roundUuids);

    @Modifying
    @Query("DELETE FROM MockExamRoundItem i WHERE i.mockExamRoundUuid = :mockExamRoundUuid")
    void deleteByMockExamRoundUuid(@Param("mockExamRoundUuid") UUID mockExamRoundUuid);
}
