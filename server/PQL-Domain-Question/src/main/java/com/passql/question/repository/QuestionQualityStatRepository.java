package com.passql.question.repository;

import com.passql.question.entity.QuestionQualityStat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface QuestionQualityStatRepository extends JpaRepository<QuestionQualityStat, UUID> {

    /** 문제 1건의 보기 키별 선택 수·정답 수 (선택 분포) */
    @Query(value = """
            SELECT selected_choice_key AS choiceKey,
                   COUNT(*) AS selectedCount,
                   SUM(CASE WHEN is_correct THEN 1 ELSE 0 END) AS correctCount
            FROM submission
            WHERE question_uuid = :questionUuid
            GROUP BY selected_choice_key
            ORDER BY selected_choice_key
            """, nativeQuery = true)
    List<ChoiceSelectionProjection> findChoiceSelectionsByQuestionUuid(@Param("questionUuid") UUID questionUuid);

    /** 보기 키별 선택 집계 행 */
    interface ChoiceSelectionProjection {
        String getChoiceKey();

        Long getSelectedCount();

        Long getCorrectCount();
    }
}
