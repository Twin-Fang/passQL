package com.passql.question.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.ChoiceGenerationMode;
import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.repository.QuestionChoiceSetRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

/**
 * 정책에 따라 사용자에게 제공할 선택지 세트를 resolve 한다.
 * <p>
 * 호출자(QuestionController)가 memberUuid로 ChoiceGenerationMode를 조회해 전달한다.
 * 이 컴포넌트는 Member 도메인에 의존하지 않는다.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ChoiceSetResolver {

    private final QuestionService questionService;
    private final QuestionChoiceSetRepository choiceSetRepository;
    private final ChoiceSetGenerationService choiceSetGenerationService;

    /**
     * @param mode 호출자가 조회한 사용자의 선택지 생성 모드
     */
    public QuestionChoiceSet resolveForUser(UUID questionUuid, UUID memberUuid, ChoiceGenerationMode mode) {
        Question question = questionService.getQuestionEntity(questionUuid);

        // 고정 보기 정책은 실행 모드보다 먼저 (Oracle 전용 개념형도 고정 세트 출제, #511)
        if (question.getChoiceSetPolicy() == ChoiceSetPolicy.CURATED_ONLY) {
            return resolveCurated(question, memberUuid, mode);
        }

        if (question.getExecutionMode() == ExecutionMode.CONCEPT_ONLY) {
            return resolveConcept(questionUuid, memberUuid, mode);
        }

        switch (question.getChoiceSetPolicy()) {
            case AI_ONLY:
            case ODD_ONE_OUT:
                return resolveAiOnly(questionUuid, memberUuid, mode);
            case RESULT_MATCH:
                return resolveResultMatch(questionUuid, memberUuid, mode);
            case HYBRID:
                throw new CustomException(ErrorCode.CHOICE_SET_POLICY_NOT_IMPLEMENTED,
                        "HYBRID 정책은 아직 지원되지 않습니다.");
            default:
                throw new CustomException(ErrorCode.CHOICE_SET_POLICY_NOT_IMPLEMENTED,
                        "알 수 없는 정책: " + question.getChoiceSetPolicy());
        }
    }

    /**
     * 고정 보기: 관리자 검증 세트 > 모드 무관 그대로 (AI 호출·프리페치 소비 없음)
     * 고정 세트가 없으면 사용자가 막히지 않게 실행 모드별 AI 경로로 대체
     */
    private QuestionChoiceSet resolveCurated(Question question, UUID memberUuid, ChoiceGenerationMode mode) {
        UUID questionUuid = question.getQuestionUuid();
        Optional<QuestionChoiceSet> curatedSet = choiceSetRepository
                .findFirstByQuestionUuidAndStatusAndSourceInOrderByCreatedAtDesc(
                        questionUuid, ChoiceSetStatus.OK, ChoiceSetSource.CURATED_SOURCES);
        if (curatedSet.isPresent()) {
            log.info("[resolver] curated HIT: questionUuid={}, setUuid={}", questionUuid, curatedSet.get().getChoiceSetUuid());
            return curatedSet.get();
        }

        log.warn("[resolver] curated set missing, fallback to ai : questionUuid={}", questionUuid);
        if (question.getExecutionMode() == ExecutionMode.CONCEPT_ONLY) {
            return resolveConcept(questionUuid, memberUuid, mode);
        }
        return resolveAiOnly(questionUuid, memberUuid, mode);
    }

    private QuestionChoiceSet resolveConcept(UUID questionUuid, UUID memberUuid, ChoiceGenerationMode mode) {
        if (mode == ChoiceGenerationMode.REAL) {
            log.info("[resolver] concept REAL mode, runtime generation: questionUuid={}", questionUuid);
            return choiceSetGenerationService.generateConcept(questionUuid, memberUuid, ChoiceSetSource.AI_RUNTIME);
        }

        // 연습 모드: 1순위 본인 프리페치 → 2순위 전체 OK → 미스 시 생성
        Optional<QuestionChoiceSet> prefetched = choiceSetRepository
                .findFirstByQuestionUuidAndGeneratedForMemberUuidAndSourceAndStatusAndConsumedAtIsNullOrderByCreatedAtDesc(
                        questionUuid, memberUuid, ChoiceSetSource.AI_PREFETCH, ChoiceSetStatus.OK);
        if (prefetched.isPresent()) {
            QuestionChoiceSet set = prefetched.get();
            choiceSetRepository.markConsumed(set.getChoiceSetUuid(), LocalDateTime.now());
            log.info("[resolver] concept prefetch HIT: questionUuid={}, setUuid={}", questionUuid, set.getChoiceSetUuid());
            return set;
        }

        Optional<QuestionChoiceSet> reusable = choiceSetRepository
                .findFirstByQuestionUuidAndStatusOrderByCreatedAtDesc(questionUuid, ChoiceSetStatus.OK);
        if (reusable.isPresent()) {
            log.info("[resolver] concept PRACTICE reuse HIT: questionUuid={}", questionUuid);
            return reusable.get();
        }

        log.info("[resolver] concept MISS, runtime generation: questionUuid={}", questionUuid);
        return choiceSetGenerationService.generateConcept(questionUuid, memberUuid, ChoiceSetSource.AI_RUNTIME);
    }

    private QuestionChoiceSet resolveAiOnly(UUID questionUuid, UUID memberUuid, ChoiceGenerationMode mode) {
        if (mode == ChoiceGenerationMode.REAL) {
            log.info("[resolver] ai-only REAL mode, runtime generation: questionUuid={}", questionUuid);
            return choiceSetGenerationService.generate(questionUuid, memberUuid, ChoiceSetSource.AI_RUNTIME);
        }

        // 연습 모드: 1순위 본인 프리페치 → 2순위 전체 OK → 미스 시 생성
        Optional<QuestionChoiceSet> prefetched = choiceSetRepository
                .findFirstByQuestionUuidAndGeneratedForMemberUuidAndSourceAndStatusAndConsumedAtIsNullOrderByCreatedAtDesc(
                        questionUuid, memberUuid, ChoiceSetSource.AI_PREFETCH, ChoiceSetStatus.OK);
        if (prefetched.isPresent()) {
            QuestionChoiceSet set = prefetched.get();
            choiceSetRepository.markConsumed(set.getChoiceSetUuid(), LocalDateTime.now());
            log.info("[resolver] ai-only prefetch HIT: questionUuid={}, setUuid={}", questionUuid, set.getChoiceSetUuid());
            return set;
        }

        Optional<QuestionChoiceSet> reusable = choiceSetRepository
                .findFirstByQuestionUuidAndStatusOrderByCreatedAtDesc(questionUuid, ChoiceSetStatus.OK);
        if (reusable.isPresent()) {
            log.info("[resolver] ai-only PRACTICE reuse HIT: questionUuid={}", questionUuid);
            return reusable.get();
        }

        log.info("[resolver] ai-only MISS, runtime generation: questionUuid={}, memberUuid={}", questionUuid, memberUuid);
        return choiceSetGenerationService.generate(questionUuid, memberUuid, ChoiceSetSource.AI_RUNTIME);
    }

    private QuestionChoiceSet resolveResultMatch(UUID questionUuid, UUID memberUuid, ChoiceGenerationMode mode) {
        if (mode == ChoiceGenerationMode.REAL) {
            log.info("[resolver] result-match REAL mode, runtime generation: questionUuid={}", questionUuid);
            return choiceSetGenerationService.generateResultMatch(questionUuid, memberUuid, ChoiceSetSource.AI_RUNTIME);
        }

        // 연습 모드: 1순위 본인 프리페치 → 2순위 전체 OK → 미스 시 생성
        Optional<QuestionChoiceSet> prefetched = choiceSetRepository
                .findFirstByQuestionUuidAndGeneratedForMemberUuidAndSourceAndStatusAndConsumedAtIsNullOrderByCreatedAtDesc(
                        questionUuid, memberUuid, ChoiceSetSource.AI_PREFETCH, ChoiceSetStatus.OK);
        if (prefetched.isPresent()) {
            QuestionChoiceSet set = prefetched.get();
            choiceSetRepository.markConsumed(set.getChoiceSetUuid(), LocalDateTime.now());
            log.info("[resolver] result-match prefetch HIT: questionUuid={}, setUuid={}", questionUuid, set.getChoiceSetUuid());
            return set;
        }

        Optional<QuestionChoiceSet> reusable = choiceSetRepository
                .findFirstByQuestionUuidAndStatusOrderByCreatedAtDesc(questionUuid, ChoiceSetStatus.OK);
        if (reusable.isPresent()) {
            log.info("[resolver] result-match PRACTICE reuse HIT: questionUuid={}", questionUuid);
            return reusable.get();
        }

        log.info("[resolver] result-match MISS, runtime generation: questionUuid={}", questionUuid);
        return choiceSetGenerationService.generateResultMatch(questionUuid, memberUuid, ChoiceSetSource.AI_RUNTIME);
    }
}
