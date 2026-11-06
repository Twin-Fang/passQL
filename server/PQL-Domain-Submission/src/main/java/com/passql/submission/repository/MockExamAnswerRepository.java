package com.passql.submission.repository;

import com.passql.submission.constant.MockExamAttemptStatus;
import com.passql.submission.entity.MockExamAnswer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MockExamAnswerRepository extends JpaRepository<MockExamAnswer, UUID> {

    List<MockExamAnswer> findByMockExamAttemptUuid(UUID mockExamAttemptUuid);

    Optional<MockExamAnswer> findByMockExamAttemptUuidAndMockExamRoundItemUuid(UUID mockExamAttemptUuid,
                                                                               UUID mockExamRoundItemUuid);

    /**
     * 문항 통계: 회차의 채점된 응시에서 문항별 보기 선택 수 (채점 때 50문항 답 행을 모두 만들어 안 고름도 셈)
     * Object[] = { UUID roundItemUuid, String selectedChoiceKey(null: 안 고름), Long count }
     */
    @Query("""
            SELECT ans.mockExamRoundItemUuid, ans.selectedChoiceKey, COUNT(ans)
            FROM MockExamAnswer ans
            WHERE ans.mockExamAttemptUuid IN (
                SELECT a.mockExamAttemptUuid FROM MockExamAttempt a
                WHERE a.mockExamRoundUuid = :mockExamRoundUuid AND a.status = :submittedStatus)
            GROUP BY ans.mockExamRoundItemUuid, ans.selectedChoiceKey
            """)
    List<Object[]> countChoicePicksByItem(@Param("mockExamRoundUuid") UUID mockExamRoundUuid,
                                          @Param("submittedStatus") MockExamAttemptStatus submittedStatus);
}
