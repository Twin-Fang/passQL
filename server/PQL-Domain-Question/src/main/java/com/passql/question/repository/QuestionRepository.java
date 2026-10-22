package com.passql.question.repository;

import com.passql.question.constant.ExecutionMode;
import com.passql.question.entity.Question;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface QuestionRepository extends JpaRepository<Question, UUID>, JpaSpecificationExecutor<Question> {

    List<Question> findByIsActiveTrue();

    // 선택지 생성 불가(FAILED만 있고 OK 없음) 문제 제외한 활성 문제 — 데일리 세트 자동 선정용 (#358)
    @Query(value = "SELECT * FROM question WHERE is_active = true "
            + "AND NOT (EXISTS (SELECT 1 FROM question_choice_set f WHERE f.question_uuid = question.question_uuid AND f.status = 'FAILED') "
            + "AND NOT EXISTS (SELECT 1 FROM question_choice_set o WHERE o.question_uuid = question.question_uuid AND o.status = 'OK'))",
            nativeQuery = true)
    List<Question> findPlayableActive();

    // 풀 수 있는 활성 문제 uuid 만 (선택지 생성 실패만 있는 문제 제외) — 랜덤 풀기 후보용, 엔티티 전체를 올리지 않음
    @Query(value = "SELECT CAST(question_uuid AS varchar) FROM question WHERE is_active = true "
            + "AND NOT (EXISTS (SELECT 1 FROM question_choice_set f WHERE f.question_uuid = question.question_uuid AND f.status = 'FAILED') "
            + "AND NOT EXISTS (SELECT 1 FROM question_choice_set o WHERE o.question_uuid = question.question_uuid AND o.status = 'OK'))",
            nativeQuery = true)
    List<String> findPlayableActiveQuestionUuids();

    /** 대시보드 집계용 — 전체 활성 문제 수 count 쿼리 */
    long countByIsActiveTrue();

    List<Question> findByTopicUuid(UUID topicUuid);

    Page<Question> findByIsActiveTrue(Pageable pageable);

    @Query("SELECT q FROM Question q WHERE q.isActive = true" +
           " AND (:topicUuid IS NULL OR q.topicUuid = :topicUuid)" +
           " AND (:difficulty IS NULL OR q.difficulty = :difficulty)" +
           " AND (:executionMode IS NULL OR q.executionMode = :executionMode)" +
           " AND (:isLatestTrend IS NULL OR q.isLatestTrend = :isLatestTrend)")
    Page<Question> findByFilters(
            @Param("topicUuid") UUID topicUuid,
            @Param("difficulty") Integer difficulty,
            @Param("executionMode") ExecutionMode executionMode,
            @Param("isLatestTrend") Boolean isLatestTrend,
            Pageable pageable
    );

    // 토픽별 활성 최신 경향 문제 수 (경향 화면·토픽 목록 배지, #523)
    @Query("SELECT q.topicUuid AS topicUuid, COUNT(q) AS questionCount FROM Question q" +
           " WHERE q.isActive = true AND q.isLatestTrend = true GROUP BY q.topicUuid")
    List<TopicQuestionCountProjection> countActiveLatestTrendByTopic();

    // 최신 경향 지정 후보: 활성 + 고정 보기 정책 + 고정 OK 세트 보유 (2026 경향 양산분 등록 경로, #511·#523)
    @Query("SELECT q FROM Question q WHERE q.isActive = true" +
           " AND q.choiceSetPolicy = com.passql.question.constant.ChoiceSetPolicy.CURATED_ONLY" +
           " AND EXISTS (SELECT 1 FROM QuestionChoiceSet s WHERE s.questionUuid = q.questionUuid" +
           " AND s.status = com.passql.question.constant.ChoiceSetStatus.OK" +
           " AND s.source IN (com.passql.question.constant.ChoiceSetSource.ADMIN_SEED, com.passql.question.constant.ChoiceSetSource.ADMIN_CURATED))" +
           " ORDER BY q.createdAt ASC")
    List<Question> findLatestTrendCandidates();

    @Query("SELECT q FROM Question q WHERE q.isActive = true" +
           " AND (:topicUuid IS NULL OR q.topicUuid = :topicUuid)" +
           " AND (:difficulty IS NULL OR q.difficulty = :difficulty)" +
           " AND (:executionMode IS NULL OR q.executionMode = :executionMode)" +
           " ORDER BY q.createdAt DESC")
    List<Question> findByFiltersAll(
            @Param("topicUuid") UUID topicUuid,
            @Param("difficulty") Integer difficulty,
            @Param("executionMode") ExecutionMode executionMode,
            Pageable pageable
    );

    // 선택지 생성이 실패만 한 문제(FAILED 있고 OK 없음)는 풀 수 없으므로 추천·데일리 후보에서 제외 (#358)
    // PostgreSQL: RAND() 대신 RANDOM() 사용
    @Query(value = "SELECT * FROM question WHERE is_active = true AND NOT (EXISTS (SELECT 1 FROM question_choice_set f WHERE f.question_uuid = question.question_uuid AND f.status = 'FAILED') AND NOT EXISTS (SELECT 1 FROM question_choice_set o WHERE o.question_uuid = question.question_uuid AND o.status = 'OK')) ORDER BY RANDOM() LIMIT :size", nativeQuery = true)
    List<Question> findRandomActive(@Param("size") int size);

    // 복수 UUID 제외 — 세션 내 이미 추천된 문제를 제외할 때 사용
    // CAST(... AS varchar): 프로젝트 기존 패턴 통일 (::text 캐스팅 대신)
    @Query(value = "SELECT * FROM question WHERE is_active = true AND CAST(question_uuid AS varchar) NOT IN (:excludeUuids) AND NOT (EXISTS (SELECT 1 FROM question_choice_set f WHERE f.question_uuid = question.question_uuid AND f.status = 'FAILED') AND NOT EXISTS (SELECT 1 FROM question_choice_set o WHERE o.question_uuid = question.question_uuid AND o.status = 'OK')) ORDER BY RANDOM() LIMIT :size", nativeQuery = true)
    List<Question> findRandomActiveExcludingList(@Param("size") int size, @Param("excludeUuids") List<String> excludeUuids);

    @Query("SELECT q.questionUuid FROM Question q WHERE q.isActive = true ORDER BY q.createdAt ASC")
    List<UUID> findActiveUuidsOrderedByCreatedAt();

    @Query("SELECT q.questionUuid FROM Question q WHERE q.isActive = true AND q.choiceSetPolicy = com.passql.question.constant.ChoiceSetPolicy.AI_ONLY")
    List<UUID> findActiveAiOnlyUuids();

    @Query(value = "SELECT q.topic_uuid, COUNT(*) FROM question q WHERE q.is_active = true GROUP BY q.topic_uuid", nativeQuery = true)
    List<Object[]> countActiveByTopic();

    /**
     * 임베딩 색인 상태 확인용 — 활성 문제 전체 UUID를 문자열로 반환.
     * Hibernate JPQL은 UUID → String 캐스팅이 DB 종속적이므로 네이티브 쿼리 사용.
     * SubmissionRepository의 CAST(question_uuid AS varchar) 패턴과 동일.
     */
    @Query(value = "SELECT CAST(q.question_uuid AS varchar) FROM question q WHERE q.is_active = true", nativeQuery = true)
    List<String> findAllActiveQuestionUuids();
}
