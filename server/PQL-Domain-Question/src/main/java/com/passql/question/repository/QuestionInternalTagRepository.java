package com.passql.question.repository;

import com.passql.question.entity.QuestionInternalTag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface QuestionInternalTagRepository extends JpaRepository<QuestionInternalTag, UUID> {

    List<QuestionInternalTag> findByQuestionUuidOrderByTagAsc(UUID questionUuid);

    List<QuestionInternalTag> findByQuestionUuidIn(Collection<UUID> questionUuids);

    /** 문제 태그 전체 즉시 삭제 (벌크 DELETE: 같은 트랜잭션에서 같은 태그 재저장 시 INSERT 선행 충돌 방지) */
    @Modifying(flushAutomatically = true)
    @Query("DELETE FROM QuestionInternalTag t WHERE t.questionUuid = :questionUuid")
    void deleteByQuestionUuid(@Param("questionUuid") UUID questionUuid);

    /** 태그별 문제 수 (전체·활성), 태그 이름순 */
    @Query("SELECT t.tag AS tag, COUNT(t) AS questionCount, "
            + "SUM(CASE WHEN q.isActive = true THEN 1 ELSE 0 END) AS activeQuestionCount "
            + "FROM QuestionInternalTag t JOIN Question q ON q.questionUuid = t.questionUuid "
            + "GROUP BY t.tag ORDER BY t.tag")
    List<QuestionInternalTagCountProjection> countQuestionsByTag();
}
