package com.passql.application.service;

import com.passql.ai.dto.AiResult;
import com.passql.application.service.explanation.ChoiceSetExplanationGenerationResult;
import com.passql.application.service.explanation.ChoiceSetExplanationGenerator;
import com.passql.application.service.explanation.ChoiceSetExplanationPrompt;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.constant.ChoiceExplanationStatus;
import com.passql.question.dto.explanation.ChoiceExplanation;
import com.passql.question.dto.explanation.ChoiceExplanationResponse;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import com.passql.question.repository.QuestionRepository;
import com.passql.question.service.ChoiceExplanationComposer;
import com.passql.question.service.QuestionService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.Executor;
import java.util.concurrent.RejectedExecutionException;

/**
 * 선택지 세트 구조화 AI 해설 (#496, #521): 세트당 1회 생성·저장, 조회는 저장본 즉시 반환, 없으면 백그라운드 생성
 * 생성 맡기는 DB 조건부 UPDATE 1건 성공한 요청만 (서버 여러 대·동시 요청 중복 호출 방지)
 * Gemini 호출은 DB 트랜잭션 밖에서 하고 저장만 짧게 한다
 */
@Slf4j
@Service
public class ChoiceExplanationService {

    // 생성 재시도 상한 (FAILED 세트를 다시 맡는 최대 시도 횟수)
    static final int MAX_GENERATION_ATTEMPT_COUNT = 3;
    // GENERATING 이 이 시간보다 오래되면 멈춘 것으로 보고 다시 맡음 (호출 2회 x 최대 50초 + 여유)
    static final long STALE_GENERATING_SECONDS = 180;
    // 생성 중 응답의 다시 조회 간격 (밀리초)
    static final int RETRY_AFTER_MILLISECONDS = 1500;
    // 출시 앱 diff-explain(동기) 경로에서 다른 요청의 생성 완료를 기다리는 상한·간격
    static final long LEGACY_WAIT_MILLISECONDS = 25_000;
    static final long LEGACY_POLL_INTERVAL_MILLISECONDS = 1_000;
    // 고정 세트 해설 프롬프트 버전 표시값 (AI 생성 아님)
    private static final int CURATED_EXPLANATION_PROMPT_VERSION = 0;

    private final QuestionRepository questionRepository;
    private final QuestionChoiceSetRepository choiceSetRepository;
    private final QuestionChoiceSetItemRepository choiceSetItemRepository;
    private final ChoiceSetExplanationGenerator explanationGenerator;
    private final Executor aiTaskExecutor;

    public ChoiceExplanationService(QuestionRepository questionRepository,
                                    QuestionChoiceSetRepository choiceSetRepository,
                                    QuestionChoiceSetItemRepository choiceSetItemRepository,
                                    ChoiceSetExplanationGenerator explanationGenerator,
                                    @Qualifier("aiTaskExecutor") Executor aiTaskExecutor) {
        this.questionRepository = questionRepository;
        this.choiceSetRepository = choiceSetRepository;
        this.choiceSetItemRepository = choiceSetItemRepository;
        this.explanationGenerator = explanationGenerator;
        this.aiTaskExecutor = aiTaskExecutor;
    }

    /**
     * 해설 조회 (기다리지 않음): 고정 세트 근거 > 구조화 저장본(낡았으면 백그라운드 재생성) > 생성 요청 후 GENERATING
     * 재시도 상한까지 실패한 세트 > FAILED (옛 해설 글이 있으면 text 로)
     */
    public ChoiceExplanationResponse getChoiceExplanation(Question question, UUID choiceSetUuid, String selectedChoiceKey) {
        QuestionChoiceSet choiceSet = getChoiceSet(choiceSetUuid);
        QuestionChoiceSetItem selectedItem = getSelectedItem(choiceSetUuid, selectedChoiceKey);

        // 고정 세트는 검증 근거 해설 그대로 (AI 생성·덮어쓰기 없음, #511)
        if (QuestionService.isCuratedChoiceSet(question, choiceSet)) {
            return readyTextResponse(choiceSetUuid, selectedChoiceKey, curatedExplanationText(selectedItem),
                    CURATED_EXPLANATION_PROMPT_VERSION);
        }
        ChoiceExplanation explanation = ChoiceExplanationComposer.composeOrNull(choiceSet.getExplanationJson(), selectedChoiceKey);
        if (explanation != null) {
            if (isStalePromptVersion(choiceSet)) requestBackgroundGeneration(choiceSetUuid);
            return new ChoiceExplanationResponse(ChoiceExplanationStatus.READY, choiceSetUuid, selectedChoiceKey,
                    explanation, ChoiceExplanationComposer.toMarkdown(explanation), choiceSet.getExplanationPromptVersion(), null);
        }

        String legacyText = legacyExplanationTextOrNull(selectedItem);
        boolean isClaimed = requestBackgroundGeneration(choiceSetUuid);
        boolean isGenerating = isClaimed || choiceSet.getExplanationStatus() == null
                || choiceSet.getExplanationStatus() == ChoiceExplanationStatus.GENERATING;
        if (!isGenerating) {
            log.info("[choice explanation] attempts exhausted : choiceSet={}", choiceSetUuid);
            return new ChoiceExplanationResponse(ChoiceExplanationStatus.FAILED, choiceSetUuid, selectedChoiceKey,
                    null, legacyText, null, null);
        }
        return new ChoiceExplanationResponse(ChoiceExplanationStatus.GENERATING, choiceSetUuid, selectedChoiceKey,
                null, legacyText, null, RETRY_AFTER_MILLISECONDS);
    }

    /**
     * 출시 앱 diff-explain(동기) 해설 글: 고정 세트 근거 > 구조화 저장본 마크다운 > 옛 해설 글(백그라운드 생성 요청)
     * > 직접 생성 또는 다른 요청의 생성 완료 대기(25초) > 실패 시 AI_UNAVAILABLE
     */
    public AiResult getOrGenerateExplanationText(Question question, UUID choiceSetUuid, String selectedChoiceKey) {
        ChoiceExplanationResponse response = getChoiceExplanation(question, choiceSetUuid, selectedChoiceKey);
        if (response.status() == ChoiceExplanationStatus.READY || response.text() != null) {
            return new AiResult(response.text(), response.promptVersion() != null ? response.promptVersion() : 0);
        }
        // 위 조회가 생성을 맡아 백그라운드로 돌렸거나 다른 요청이 생성 중 > 저장될 때까지 대기
        ChoiceExplanation explanation = waitForStoredExplanation(choiceSetUuid, selectedChoiceKey);
        if (explanation == null) {
            log.warn("[choice explanation] rejected 503 : no explanation within {}ms, choiceSet={}", LEGACY_WAIT_MILLISECONDS, choiceSetUuid);
            throw new CustomException(ErrorCode.AI_UNAVAILABLE);
        }
        return new AiResult(ChoiceExplanationComposer.toMarkdown(explanation), ChoiceSetExplanationPrompt.PROMPT_VERSION);
    }

    /**
     * 백그라운드 생성 요청: 맡기 성공 시 AI 작업 스레드에서 생성
     * @return 이번 요청이 생성을 맡았는지
     */
    public boolean requestBackgroundGeneration(UUID choiceSetUuid) {
        if (!claimGeneration(choiceSetUuid)) return false;
        try {
            aiTaskExecutor.execute(() -> generateAndStoreSafely(choiceSetUuid));
            return true;
        } catch (RejectedExecutionException e) {
            // 작업 대기열 가득 > 실패 기록 (다음 조회·백필에서 다시 맡음)
            log.warn("[choice explanation] rejected : ai task queue full, choiceSet={}", choiceSetUuid);
            choiceSetRepository.markExplanationFailed(choiceSetUuid, LocalDateTime.now());
            return false;
        }
    }

    /**
     * 세트 해설 미리 생성 (세트 저장 직후·백필, 호출 스레드에서 실행)
     * @return 새로 만든 해설 수 (0 또는 1)
     */
    public int pregenerateExplanation(UUID choiceSetUuid) {
        QuestionChoiceSet choiceSet = choiceSetRepository.findById(choiceSetUuid).orElse(null);
        if (choiceSet == null) return 0;
        Question question = questionRepository.findById(choiceSet.getQuestionUuid()).orElse(null);
        if (question == null || QuestionService.isCuratedChoiceSet(question, choiceSet)) return 0;
        if (!claimGeneration(choiceSetUuid)) return 0;
        return generateAndStore(question, choiceSetUuid) ? 1 : 0;
    }

    /**
     * 해설 필요한 세트 백필 (없음·낡은 버전·재시도 가능 실패): 최신 세트부터 setLimit 개, 세트마다 실패해도 계속
     * @return 새로 만든 해설 수
     */
    public int backfillMissingExplanations(int setLimit) {
        List<UUID> choiceSetUuids = choiceSetRepository.findChoiceSetUuidsNeedingExplanation(
                ChoiceSetExplanationPrompt.PROMPT_VERSION, MAX_GENERATION_ATTEMPT_COUNT, PageRequest.of(0, setLimit));
        int createdCount = 0;
        for (UUID choiceSetUuid : choiceSetUuids) {
            try {
                createdCount += pregenerateExplanation(choiceSetUuid);
            } catch (Exception e) {
                log.warn("[choice explanation] backfill failed : choiceSet={}", choiceSetUuid, e);
            }
        }
        return createdCount;
    }

    /** 생성 맡기 (조건부 UPDATE, 서버 여러 대 공통) */
    private boolean claimGeneration(UUID choiceSetUuid) {
        LocalDateTime now = LocalDateTime.now();
        return choiceSetRepository.claimExplanationGeneration(choiceSetUuid, ChoiceSetExplanationPrompt.PROMPT_VERSION,
                MAX_GENERATION_ATTEMPT_COUNT, now.minusSeconds(STALE_GENERATING_SECONDS), now) == 1;
    }

    /** 백그라운드 작업용: 예외를 삼키고 실패로 기록 (작업 스레드 종료 방지) */
    private void generateAndStoreSafely(UUID choiceSetUuid) {
        try {
            QuestionChoiceSet choiceSet = getChoiceSet(choiceSetUuid);
            Question question = questionRepository.findById(choiceSet.getQuestionUuid())
                    .orElseThrow(() -> new CustomException(ErrorCode.QUESTION_NOT_FOUND));
            generateAndStore(question, choiceSetUuid);
        } catch (Exception e) {
            log.error("[choice explanation] background generation failed : choiceSet={}", choiceSetUuid, e);
            choiceSetRepository.markExplanationFailed(choiceSetUuid, LocalDateTime.now());
        }
    }

    /** 맡은 세트 생성 > 검증 통과 시 READY 저장, 아니면 FAILED (옛 해설 JSON 유지) */
    private boolean generateAndStore(Question question, UUID choiceSetUuid) {
        List<QuestionChoiceSetItem> items = choiceSetItemRepository.findByChoiceSetUuidOrderBySortOrderAsc(choiceSetUuid);
        ChoiceSetExplanationGenerationResult result = explanationGenerator.generate(question, items);
        if (!result.isSuccessful()) {
            log.warn("[choice explanation] generation failed : choiceSet={} attempts={} violations={}",
                    choiceSetUuid, result.attemptCount(), result.validation().violations());
            choiceSetRepository.markExplanationFailed(choiceSetUuid, LocalDateTime.now());
            return false;
        }
        choiceSetRepository.saveReadyExplanation(choiceSetUuid, ChoiceExplanationComposer.toJson(result.explanation()),
                ChoiceSetExplanationPrompt.PROMPT_VERSION, LocalDateTime.now());
        log.info("[choice explanation] generated : choiceSet={} attempts={} elapsedMs={} warnings={}",
                choiceSetUuid, result.attemptCount(), result.elapsedMilliseconds(), result.validation().warnings().size());
        return true;
    }

    /** 저장본이 생길 때까지 대기 (FAILED 확정 또는 상한 도달 > null) */
    private ChoiceExplanation waitForStoredExplanation(UUID choiceSetUuid, String selectedChoiceKey) {
        long deadline = System.currentTimeMillis() + LEGACY_WAIT_MILLISECONDS;
        while (System.currentTimeMillis() < deadline) {
            QuestionChoiceSet choiceSet = getChoiceSet(choiceSetUuid);
            ChoiceExplanation explanation = ChoiceExplanationComposer.composeOrNull(choiceSet.getExplanationJson(), selectedChoiceKey);
            if (explanation != null) return explanation;
            if (choiceSet.getExplanationStatus() == ChoiceExplanationStatus.FAILED) return null;
            try {
                Thread.sleep(LEGACY_POLL_INTERVAL_MILLISECONDS);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return null;
            }
        }
        return null;
    }

    private QuestionChoiceSet getChoiceSet(UUID choiceSetUuid) {
        return choiceSetRepository.findById(choiceSetUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.CHOICE_SET_NOT_FOUND));
    }

    /** 세트에 없는 선택지 키 > INVALID_INPUT_VALUE */
    private QuestionChoiceSetItem getSelectedItem(UUID choiceSetUuid, String selectedChoiceKey) {
        return choiceSetItemRepository.findByChoiceSetUuidOrderBySortOrderAsc(choiceSetUuid).stream()
                .filter(item -> item.getChoiceKey().equals(selectedChoiceKey))
                .findFirst()
                .orElseThrow(() -> new CustomException(ErrorCode.INVALID_INPUT_VALUE));
    }

    private boolean isStalePromptVersion(QuestionChoiceSet choiceSet) {
        return !Integer.valueOf(ChoiceSetExplanationPrompt.PROMPT_VERSION).equals(choiceSet.getExplanationPromptVersion());
    }

    private static String curatedExplanationText(QuestionChoiceSetItem item) {
        return item.getExplanation() != null ? item.getExplanation() : item.getRationale();
    }

    /** 보기별 옛 해설 글 (#496 저장분, 구조화 해설 생기기 전 임시 표시용) */
    private static String legacyExplanationTextOrNull(QuestionChoiceSetItem item) {
        String explanation = item.getExplanation();
        return explanation == null || explanation.isBlank() ? null : explanation;
    }

    private static ChoiceExplanationResponse readyTextResponse(UUID choiceSetUuid, String selectedChoiceKey,
                                                               String text, int promptVersion) {
        return new ChoiceExplanationResponse(ChoiceExplanationStatus.READY, choiceSetUuid, selectedChoiceKey,
                null, text, promptVersion, null);
    }
}
