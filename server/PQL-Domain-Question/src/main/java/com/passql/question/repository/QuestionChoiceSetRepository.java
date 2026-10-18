package com.passql.question.repository;

import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.entity.QuestionChoiceSet;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface QuestionChoiceSetRepository extends JpaRepository<QuestionChoiceSet, UUID> {

    /**
     * 프리페치 캐시 조회: 특정 멤버·특정 문제에 대해 아직 소비되지 않은
     * AI_PREFETCH + status=OK 세트 중 가장 최근 것.
     */
    Optional<QuestionChoiceSet>
        findFirstByQuestionUuidAndGeneratedForMemberUuidAndSourceAndStatusAndConsumedAtIsNullOrderByCreatedAtDesc(
            UUID questionUuid, UUID generatedForMemberUuid,
            ChoiceSetSource source, ChoiceSetStatus status);

    boolean existsByQuestionUuidAndGeneratedForMemberUuidAndSourceAndStatusAndConsumedAtIsNull(
            UUID questionUuid, UUID generatedForMemberUuid,
            ChoiceSetSource source, ChoiceSetStatus status);

    List<QuestionChoiceSet> findByQuestionUuidAndSourceOrderByCreatedAtDesc(UUID questionUuid, ChoiceSetSource source);

    List<QuestionChoiceSet> findByQuestionUuidOrderByCreatedAtDesc(UUID questionUuid);

    /**
     * 연습 모드 재사용 조회: 특정 문제에 대해 status=OK인 선택지 중 가장 최근 것.
     * generatedForMemberUuid 무관 — 다른 사용자가 생성한 것도 재사용 가능.
     */
    Optional<QuestionChoiceSet>
        findFirstByQuestionUuidAndStatusOrderByCreatedAtDesc(
            UUID questionUuid, ChoiceSetStatus status);

    /** 고정 세트 조회 (#511): 특정 출처(ADMIN_SEED·ADMIN_CURATED) 중 status 일치 최신 1개 */
    Optional<QuestionChoiceSet>
        findFirstByQuestionUuidAndStatusAndSourceInOrderByCreatedAtDesc(
            UUID questionUuid, ChoiceSetStatus status, Collection<ChoiceSetSource> sources);

    /** 프리페치 소비 마킹 — 별도 @Transactional 빈 없이 Repository 레벨에서 직접 처리. */
    @Modifying
    @Transactional
    @Query("UPDATE QuestionChoiceSet q SET q.consumedAt = :consumedAt WHERE q.choiceSetUuid = :choiceSetUuid")
    void markConsumed(UUID choiceSetUuid, LocalDateTime consumedAt);

    @Modifying
    @Transactional
    void deleteByQuestionUuid(UUID questionUuid);

    /**
     * 해설 백필 대상 세트 (#496, #521): OK + (샌드박스 검증 통과 또는 개념 문제) + 해설 필요, 최신 순
     * 해설 필요 3가지: 상태 없음, 프롬프트 버전 낡은 READY, 재시도 상한 미만 FAILED
     * 샌드박스 미검증(AI 판단 fallback) 세트는 틀린 해설이 퍼질 수 있어 제외
     * CURATED_ONLY 문제의 고정 세트는 검증 근거가 해설이라 제외 (#511)
     */
    @Query("""
            select s.choiceSetUuid from QuestionChoiceSet s
            where s.status = com.passql.question.constant.ChoiceSetStatus.OK
              and (s.sandboxValidationPassed = true
                   or exists (select q.questionUuid from Question q
                              where q.questionUuid = s.questionUuid
                                and q.executionMode = com.passql.question.constant.ExecutionMode.CONCEPT_ONLY))
              and not exists (select cq.questionUuid from Question cq
                              where cq.questionUuid = s.questionUuid
                                and cq.choiceSetPolicy = com.passql.question.constant.ChoiceSetPolicy.CURATED_ONLY
                                and s.source in (com.passql.question.constant.ChoiceSetSource.ADMIN_SEED,
                                                 com.passql.question.constant.ChoiceSetSource.ADMIN_CURATED))
              and (s.explanationStatus is null
                   or (s.explanationStatus = com.passql.question.constant.ChoiceExplanationStatus.READY
                       and (s.explanationPromptVersion is null or s.explanationPromptVersion <> :promptVersion))
                   or (s.explanationStatus = com.passql.question.constant.ChoiceExplanationStatus.FAILED
                       and coalesce(s.explanationAttemptCount, 0) < :maxAttemptCount))
            order by s.createdAt desc
            """)
    List<UUID> findChoiceSetUuidsNeedingExplanation(@Param("promptVersion") int promptVersion,
                                                    @Param("maxAttemptCount") int maxAttemptCount,
                                                    Pageable pageable);

    /**
     * 해설 생성 맡기 (#521): 조건부 UPDATE 1건 성공한 요청만 생성 (서버 여러 대·동시 요청 중복 호출 방지)
     * 맡을 수 있는 상태 4가지: 없음, 낡은 READY(시도 횟수 1부터), 상한 미만 FAILED, 멈춘 GENERATING(staleBefore 이전)
     * @return 1 맡음, 0 다른 요청이 생성 중이거나 맡을 필요 없음
     */
    @Modifying
    @Transactional
    @Query("""
            update QuestionChoiceSet s
               set s.explanationAttemptCount = case
                       when s.explanationStatus = com.passql.question.constant.ChoiceExplanationStatus.READY then 1
                       else coalesce(s.explanationAttemptCount, 0) + 1 end,
                   s.explanationStatus = com.passql.question.constant.ChoiceExplanationStatus.GENERATING,
                   s.explanationStatusChangedAt = :now
             where s.choiceSetUuid = :choiceSetUuid
               and (s.explanationStatus is null
                    or (s.explanationStatus = com.passql.question.constant.ChoiceExplanationStatus.READY
                        and (s.explanationPromptVersion is null or s.explanationPromptVersion <> :promptVersion))
                    or (s.explanationStatus = com.passql.question.constant.ChoiceExplanationStatus.FAILED
                        and coalesce(s.explanationAttemptCount, 0) < :maxAttemptCount)
                    or (s.explanationStatus = com.passql.question.constant.ChoiceExplanationStatus.GENERATING
                        and s.explanationStatusChangedAt < :staleBefore))
            """)
    int claimExplanationGeneration(@Param("choiceSetUuid") UUID choiceSetUuid,
                                   @Param("promptVersion") int promptVersion,
                                   @Param("maxAttemptCount") int maxAttemptCount,
                                   @Param("staleBefore") LocalDateTime staleBefore,
                                   @Param("now") LocalDateTime now);

    /** 해설 저장 > READY (해설 컬럼만 갱신, 소비 시각 등 다른 컬럼 덮어쓰기 방지) */
    @Modifying
    @Transactional
    @Query("""
            update QuestionChoiceSet s
               set s.explanationJson = :explanationJson,
                   s.explanationPromptVersion = :promptVersion,
                   s.explanationStatus = com.passql.question.constant.ChoiceExplanationStatus.READY,
                   s.explanationStatusChangedAt = :now
             where s.choiceSetUuid = :choiceSetUuid
            """)
    int saveReadyExplanation(@Param("choiceSetUuid") UUID choiceSetUuid,
                             @Param("explanationJson") String explanationJson,
                             @Param("promptVersion") int promptVersion,
                             @Param("now") LocalDateTime now);

    /**
     * 생성 실패 기록 > FAILED (옛 해설 JSON 은 지우지 않음, 조회는 옛 해설이라도 계속 보여 줌)
     * 재시도는 시도 횟수 상한까지 (낡은 READY 에서 시작해도 실패가 이어지면 상한에서 멈춤)
     */
    @Modifying
    @Transactional
    @Query("""
            update QuestionChoiceSet s
               set s.explanationStatus = com.passql.question.constant.ChoiceExplanationStatus.FAILED,
                   s.explanationStatusChangedAt = :now
             where s.choiceSetUuid = :choiceSetUuid
            """)
    int markExplanationFailed(@Param("choiceSetUuid") UUID choiceSetUuid, @Param("now") LocalDateTime now);
}
