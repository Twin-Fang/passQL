package com.passql.question.service;

import com.passql.ai.client.AiGatewayClient;
import com.passql.ai.dto.*;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.service.PromptService;
import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.dto.ExecuteResult;
import com.passql.question.dto.ValidationReport;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * AI 선택지 세트 생성 + 샌드박스 검증 재시도 루프.
 * 요청 조립은 ChoiceSetGenerationRequestFactory, RESULT_MATCH 실행·비교는 ResultMatchChoiceValidator
 * <p>
 * 비트랜잭션 — AI·샌드박스 호출이 수 초 걸리므로 긴 트랜잭션 금지.
 * save는 ChoiceSetSaveService(별도 빈)에 위임하여 self-invocation 문제 방지.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ChoiceSetGenerationService {

    private static final int MAX_ATTEMPTS = 3;
    private static final String PROMPT_KEY = "generate_choice_set";
    // CONCEPT_ONLY 전용 프롬프트 키 — Sandbox 없이 텍스트 선택지 생성
    private static final String CONCEPT_PROMPT_KEY = "generate_choice_set_concept";
    // RESULT_MATCH 전용 프롬프트 키 — answerSql 실행 결과 JSON을 컨텍스트로 제공
    private static final String RESULT_MATCH_PROMPT_KEY = "generate_choice_set_result_match";
    // ODD_ONE_OUT 전용 프롬프트 키 — 기준과 같은 결과 3개 + 다른 결과 1개(정답), SandboxValidator 3:1 판정과 짝 (#699)
    private static final String ODD_ONE_OUT_PROMPT_KEY = "generate_choice_set_odd_one_out";

    private final QuestionService questionService;
    private final PromptService promptService;
    private final AiGatewayClient aiGatewayClient;
    private final SandboxValidator sandboxValidator;
    private final ResultMatchChoiceValidator resultMatchChoiceValidator;
    private final ChoiceSetSaveService choiceSetSaveService;
    private final ChoiceSetGenerationRequestFactory requestFactory;

    /**
     * CONCEPT_ONLY 전용: Sandbox 없이 AI가 텍스트 선택지를 생성한다.
     * AI의 is_correct를 그대로 신뢰하여 저장 (별도 검증 없음).
     * 최대 3회 재시도 — AI가 정확히 is_correct=true인 선택지를 1개 내려줄 때 성공.
     */
    public QuestionChoiceSet generateConcept(UUID questionUuid, UUID memberUuid, ChoiceSetSource source) {
        Question question = questionService.getQuestionEntity(questionUuid);
        PromptTemplate prompt = promptService.getActivePrompt(CONCEPT_PROMPT_KEY);
        GenerateChoiceSetRequest request = requestFactory.buildConceptRequest(question, prompt);
        log.debug("[choice-gen-concept] 요청 빌드 완료: questionUuid={}, promptKey={}", questionUuid, CONCEPT_PROMPT_KEY);

        GenerateChoiceSetResult lastResult = null;
        ErrorCode lastErrorCode = null;

        for (int attempts = 1; attempts <= MAX_ATTEMPTS; attempts++) {
            try {
                log.debug("[choice-gen-concept] AI 호출 시작: attempt={}/{}, questionUuid={}", attempts, MAX_ATTEMPTS, questionUuid);
                lastResult = aiGatewayClient.generateChoiceSet(request);
                log.debug("[choice-gen-concept] AI 응답 수신: attempt={}, choiceCount={}, questionUuid={}",
                        attempts, lastResult.choices().size(), questionUuid);

                // AI가 내려준 is_correct 집계 — 1개여야 유효
                long correctCount = lastResult.choices().stream()
                        .filter(c -> Boolean.TRUE.equals(c.isCorrect()))
                        .count();
                log.debug("[choice-gen-concept] is_correct 집계: correctCount={}, attempt={}, questionUuid={}",
                        correctCount, attempts, questionUuid);

                if (correctCount == 1) {
                    log.debug("[choice-gen-concept] 검증 통과, 저장 시작: attempt={}, questionUuid={}", attempts, questionUuid);
                    return choiceSetSaveService.saveConceptSuccess(
                            question, source, memberUuid, prompt, lastResult, attempts);
                }

                lastErrorCode = (correctCount == 0)
                        ? ErrorCode.CHOICE_SET_VALIDATION_NO_CORRECT
                        : ErrorCode.CHOICE_SET_VALIDATION_MULTIPLE_CORRECT;
                log.info("[choice-gen-concept] validation failed: code={}, attempt={}/{}, questionUuid={}",
                        lastErrorCode, attempts, MAX_ATTEMPTS, questionUuid);

            } catch (CustomException e) {
                if (e.getErrorCode() == ErrorCode.AI_FALLBACK_FAILED) {
                    log.error("[choice-gen-concept] AI fallback 실패, 재시도 불가: attempt={}, questionUuid={}", attempts, questionUuid);
                    choiceSetSaveService.saveFailed(question, source, memberUuid, prompt, lastResult, attempts, e.getErrorCode());
                    throw e;
                }
                lastErrorCode = e.getErrorCode();
                log.warn("[choice-gen-concept] transient error, retrying: code={}, attempt={}/{}",
                        lastErrorCode, attempts, MAX_ATTEMPTS);
            }
        }

        log.error("[choice-gen-concept] 최대 재시도 초과: questionUuid={}, lastErrorCode={}", questionUuid, lastErrorCode);
        choiceSetSaveService.saveFailed(question, source, memberUuid, prompt, lastResult, MAX_ATTEMPTS, lastErrorCode);
        throw new CustomException(
                lastErrorCode != null ? lastErrorCode : ErrorCode.CHOICE_SET_GENERATION_FAILED,
                "concept questionUuid=" + questionUuid);
    }

    /**
     * 선택지 세트를 AI로 생성하고 샌드박스로 검증한다.
     * 최대 3회 재시도 후 실패 시 CustomException을 던진다.
     * <p>
     * MULTIPLE_CORRECT 실패 시 이전 시도에서 정답과 동일한 결과를 낸 오답 SQL을
     * 피드백으로 누적하여 다음 AI 요청에 포함한다.
     * 이를 통해 AI가 같은 SQL 동치(equivalence) 실수를 반복하는 것을 방지한다.
     */
    public QuestionChoiceSet generate(UUID questionUuid, UUID memberUuid, ChoiceSetSource source) {
        Question question = questionService.getQuestionEntity(questionUuid);
        String promptKey = toStandardPromptKey(question.getChoiceSetPolicy());
        PromptTemplate prompt = promptService.getActivePrompt(promptKey);
        log.debug("[choice-gen] 요청 빌드 완료: questionUuid={}, promptKey={}", questionUuid, promptKey);

        ValidationReport lastReport = null;
        GenerateChoiceSetResult lastResult = null;
        ErrorCode lastErrorCode = null;

        // MULTIPLE_CORRECT 실패 시 정답과 동일한 결과를 낸 오답 SQL 누적 (피드백용)
        List<String> equivalentSqls = new ArrayList<>();
        // 실패 시 직전 시도 선택지별 실제 실행 결과 (피드백용, 매 시도 교체)
        List<String> previousChoiceResultLines = List.of();
        // 기준 SQL 실행 결과: 프롬프트가 받을 때만 첫 시도에 1회 실행 (#720)
        boolean shouldIncludeAnswerResult = requestFactory.hasAnswerResultPlaceholder(prompt);
        ExecuteResult expectedResult = null;

        for (int attempts = 1; attempts <= MAX_ATTEMPTS; attempts++) {
            try {
                // 실행 실패(SANDBOX_ANSWER_SQL_FAILED)는 아래 재시도 불가 처리로 실패 저장
                if (shouldIncludeAnswerResult && expectedResult == null) {
                    expectedResult = resultMatchChoiceValidator.executeExpectedResult(question);
                }
                // 재시도마다 피드백(동치 SQL 목록, 직전 실행 결과)을 포함한 요청을 새로 빌드
                GenerateChoiceSetRequest request = requestFactory.buildStandardRequest(
                        question, prompt, equivalentSqls, previousChoiceResultLines, expectedResult);

                log.debug("[choice-gen] AI 호출 시작: attempt={}/{}, questionUuid={}, feedbackCount={}",
                        attempts, MAX_ATTEMPTS, questionUuid, equivalentSqls.size());
                lastResult = aiGatewayClient.generateChoiceSet(request);
                log.debug("[choice-gen] AI 응답 수신: attempt={}, choiceCount={}, questionUuid={}",
                        attempts, lastResult.choices().size(), questionUuid);

                log.debug("[choice-gen] Sandbox 검증 시작: attempt={}, questionUuid={}", attempts, questionUuid);
                // policy를 validator에 전달 — ODD_ONE_OUT 유형은 다른 검증 로직 적용
                lastReport = sandboxValidator.validate(
                        lastResult.choices(),
                        question.getAnswerSql(),
                        question.getSchemaDdl(),
                        question.getSchemaSampleData(),
                        question.getChoiceSetPolicy());
                log.debug("[choice-gen] Sandbox 검증 완료: attempt={}, correctCount={}, questionUuid={}",
                        attempts, lastReport.correctCount(), questionUuid);

                if (lastReport.correctCount() == 1) {
                    log.debug("[choice-gen] 검증 통과, 저장 시작: attempt={}, questionUuid={}", attempts, questionUuid);
                    return choiceSetSaveService.saveSuccess(
                            question, source, memberUuid, prompt, lastResult, lastReport, attempts);
                }

                lastErrorCode = (lastReport.correctCount() == 0)
                        ? ErrorCode.CHOICE_SET_VALIDATION_NO_CORRECT
                        : ErrorCode.CHOICE_SET_VALIDATION_MULTIPLE_CORRECT;
                log.info("[choice-gen] validation failed: code={}, attempt={}/{}, questionUuid={}",
                        lastErrorCode, attempts, MAX_ATTEMPTS, questionUuid);

                // MULTIPLE_CORRECT 실패 시 정답과 동치인 오답 SQL을 피드백 목록에 누적
                // 다음 시도에서 AI가 동일한 SQL을 생성하지 않도록 명시적으로 금지
                if (lastErrorCode == ErrorCode.CHOICE_SET_VALIDATION_MULTIPLE_CORRECT
                        && lastResult != null) {
                    requestFactory.collectEquivalentSqls(lastResult.choices(), lastReport, equivalentSqls);
                    log.info("[choice-gen] 동치 SQL 피드백 누적: count={}, attempt={}, questionUuid={}",
                            equivalentSqls.size(), attempts, questionUuid);
                }
                // 직전 실행 결과 피드백: ODD_ONE_OUT 결과만, AI_ONLY 기준과 같음/다름 표시 포함 (#720)
                if (lastResult != null) {
                    boolean isOddOneOut = question.getChoiceSetPolicy() == ChoiceSetPolicy.ODD_ONE_OUT;
                    previousChoiceResultLines = requestFactory.toChoiceResultLines(
                            lastResult.choices(), lastReport, !isOddOneOut);
                }

            } catch (CustomException e) {
                ErrorCode ec = e.getErrorCode();
                // 재시도 불가 에러는 즉시 실패 저장 후 throw
                if (ec == ErrorCode.SANDBOX_SETUP_FAILED
                        || ec == ErrorCode.SANDBOX_ANSWER_SQL_FAILED
                        || ec == ErrorCode.AI_FALLBACK_FAILED) {
                    log.error("[choice-gen] 재시도 불가 에러: code={}, attempt={}, questionUuid={}", ec, attempts, questionUuid);
                    choiceSetSaveService.saveFailed(question, source, memberUuid, prompt, lastResult, attempts, ec);
                    throw e;
                }
                // 재시도 가능 에러 (파싱 실패, 스키마 위반 등)
                lastErrorCode = ec;
                log.warn("[choice-gen] transient error, retrying: code={}, attempt={}/{}",
                        ec, attempts, e);
            }
        }

        // 3회 다 실패 — MULTIPLE_CORRECT이고 AI isCorrect=true가 1개 이상이면 AI 판단 신뢰 후 반환
        // 단, 전부 정답(aiCorrectCount == choices.size())이면 문제로서 의미 없으므로 에러로 처리
        log.error("[choice-gen] 최대 재시도 초과: questionUuid={}, lastErrorCode={}", questionUuid, lastErrorCode);
        if (lastErrorCode == ErrorCode.CHOICE_SET_VALIDATION_MULTIPLE_CORRECT && lastResult != null) {
            long aiCorrectCount = lastResult.choices().stream()
                    .filter(GeneratedChoiceDto::isCorrect)
                    .count();
            if (aiCorrectCount >= 1 && aiCorrectCount < lastResult.choices().size()) {
                // 정답이 일부 — "맞는 것은?" 유형에서 정답 중 하나를 고르면 정답 처리되므로 문제없음
                log.warn("[choice-gen] MULTIPLE_CORRECT fallback: AI isCorrect={}개 신뢰, sandboxValidationPassed=false 저장. questionUuid={}", aiCorrectCount, questionUuid);
                return choiceSetSaveService.saveWithAiCorrect(
                        question, source, memberUuid, prompt, lastResult, MAX_ATTEMPTS);
            }
            log.error("[choice-gen] MULTIPLE_CORRECT fallback 불가: aiCorrectCount={}. questionUuid={}", aiCorrectCount, questionUuid);
        }
        choiceSetSaveService.saveFailed(question, source, memberUuid, prompt, lastResult, MAX_ATTEMPTS, lastErrorCode);
        throw new CustomException(
                lastErrorCode != null ? lastErrorCode : ErrorCode.CHOICE_SET_GENERATION_FAILED,
                "questionUuid=" + questionUuid + ", source=" + source);
    }

    /**
     * RESULT_MATCH 전용: answerSql을 Sandbox에서 실행 후 결과를 AI에 전달하여
     * 정답 결과 JSON 1개 + 오답 결과 JSON 3개를 생성한다.
     * Sandbox는 1회만 사용(answerSql 실행용) — 검증은 JSON 비교로 처리.
     */
    public QuestionChoiceSet generateResultMatch(UUID questionUuid, UUID memberUuid, ChoiceSetSource source) {
        Question question = questionService.getQuestionEntity(questionUuid);

        // schemaDdl 없이는 Sandbox 실행 불가
        if (question.getSchemaDdl() == null || question.getSchemaDdl().isBlank()) {
            throw new CustomException(ErrorCode.SANDBOX_SETUP_FAILED, "RESULT_MATCH는 schemaDdl이 필수입니다.");
        }
        if (question.getAnswerSql() == null || question.getAnswerSql().isBlank()) {
            throw new CustomException(ErrorCode.SANDBOX_ANSWER_SQL_FAILED, "RESULT_MATCH는 answerSql이 필수입니다.");
        }

        PromptTemplate prompt = promptService.getActivePrompt(RESULT_MATCH_PROMPT_KEY);
        log.debug("[choice-gen-result-match] 요청 시작: questionUuid={}", questionUuid);

        // answerSql을 Sandbox에서 1회 실행 — 이 결과를 AI 컨텍스트 + 검증에 재사용
        ExecuteResult expectedResult = resultMatchChoiceValidator.executeExpectedResult(question);
        log.debug("[choice-gen-result-match] answerSql 실행 완료: rowCount={}", expectedResult.rowCount());

        GenerateChoiceSetResult lastResult = null;
        ErrorCode lastErrorCode = null;
        // 직전 시도 채점 피드백 (첫 시도 null)
        String retryFeedback = null;

        for (int attempts = 1; attempts <= MAX_ATTEMPTS; attempts++) {
            try {
                log.debug("[choice-gen-result-match] AI 호출 시작: attempt={}/{}", attempts, MAX_ATTEMPTS);
                GenerateChoiceSetRequest request = requestFactory.buildResultMatchRequest(
                        question, prompt, expectedResult, retryFeedback);
                lastResult = aiGatewayClient.generateChoiceSet(request);
                log.debug("[choice-gen-result-match] AI 응답 수신: choiceCount={}", lastResult.choices().size());

                // JSON 비교 검증 (Sandbox 재호출 없음)
                ValidationReport report = resultMatchChoiceValidator.validate(lastResult.choices(), expectedResult);
                log.debug("[choice-gen-result-match] 검증 완료: correctCount={}", report.correctCount());

                // 같은 결과 표 보기가 2개면 재생성 (#555)
                if (report.correctCount() != 1) {
                    retryFeedback = requestFactory.toResultMatchRetryFeedback(report);
                }
                boolean hasDuplicateChoice = ChoiceBodyDuplicateFinder.findDuplicateBody(
                        lastResult.choices().stream().map(GeneratedChoiceDto::body).toList()) != null;
                if (hasDuplicateChoice) {
                    lastErrorCode = ErrorCode.CHOICE_SET_GENERATION_FAILED;
                    log.info("[choice-gen-result-match] validation failed: duplicate choice body, attempt={}/{}",
                            attempts, MAX_ATTEMPTS);
                    continue;
                }

                if (report.correctCount() == 1) {
                    log.debug("[choice-gen-result-match] 검증 통과, 저장: attempt={}", attempts);
                    return choiceSetSaveService.saveResultMatch(
                            question, source, memberUuid, prompt, lastResult, report, attempts);
                }

                lastErrorCode = (report.correctCount() == 0)
                        ? ErrorCode.CHOICE_SET_VALIDATION_NO_CORRECT
                        : ErrorCode.CHOICE_SET_VALIDATION_MULTIPLE_CORRECT;
                log.info("[choice-gen-result-match] validation failed: code={}, attempt={}/{}",
                        lastErrorCode, attempts, MAX_ATTEMPTS);

            } catch (CustomException e) {
                ErrorCode ec = e.getErrorCode();
                if (ec == ErrorCode.SANDBOX_SETUP_FAILED
                        || ec == ErrorCode.SANDBOX_ANSWER_SQL_FAILED
                        || ec == ErrorCode.AI_FALLBACK_FAILED) {
                    log.error("[choice-gen-result-match] 재시도 불가 에러: code={}, attempt={}", ec, attempts);
                    choiceSetSaveService.saveFailed(question, source, memberUuid, prompt, lastResult, attempts, ec);
                    throw e;
                }
                lastErrorCode = ec;
                log.warn("[choice-gen-result-match] transient error, retrying: code={}, attempt={}/{}",
                        ec, attempts, MAX_ATTEMPTS);
            }
        }

        log.error("[choice-gen-result-match] 최대 재시도 초과: questionUuid={}, lastErrorCode={}", questionUuid, lastErrorCode);
        choiceSetSaveService.saveFailed(question, source, memberUuid, prompt, lastResult, MAX_ATTEMPTS, lastErrorCode);
        throw new CustomException(
                lastErrorCode != null ? lastErrorCode : ErrorCode.CHOICE_SET_GENERATION_FAILED,
                "result-match questionUuid=" + questionUuid);
    }

    /** SQL 보기 정책 > 프롬프트 키 (ODD_ONE_OUT 은 정답 방향이 반대라 전용 프롬프트, 그 외 기본) */
    static String toStandardPromptKey(ChoiceSetPolicy policy) {
        return policy == ChoiceSetPolicy.ODD_ONE_OUT ? ODD_ONE_OUT_PROMPT_KEY : PROMPT_KEY;
    }
}
