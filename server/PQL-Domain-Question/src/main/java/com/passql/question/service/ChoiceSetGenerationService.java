package com.passql.question.service;

import com.passql.ai.client.AiGatewayClient;
import com.passql.ai.dto.*;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.service.PromptService;
import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.dto.ValidationReport;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;
import java.util.UUID;

/**
 * AI 선택지 세트 생성 + 샌드박스 검증 재시도 루프.
 * 요청 조립은 ChoiceSetGenerationRequestFactory, RESULT_MATCH 보기 실행·판정은 ResultTableChoiceBuilder
 * 저장은 샌드박스 검증 통과 세트만 (SQL·결과형), 개념 문제만 AI 정답 표시 사용
 * <p>
 * 비트랜잭션 — AI·샌드박스 호출이 수 초 걸리므로 긴 트랜잭션 금지.
 * save는 ChoiceSetSaveService(별도 빈)에 위임하여 self-invocation 문제 방지.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ChoiceSetGenerationService {

    private static final int MAX_ATTEMPTS = ChoiceSetAttemptRunner.MAX_ATTEMPTS;
    private static final String PROMPT_KEY = "generate_choice_set";
    // CONCEPT_ONLY 전용 프롬프트 키 — Sandbox 없이 텍스트 선택지 생성
    private static final String CONCEPT_PROMPT_KEY = "generate_choice_set_concept";
    // RESULT_MATCH 전용 프롬프트 키 (v3 이상: 오해 SQL 4개 후보, 지시문은 운영 DB 에만, #828)
    private static final String RESULT_MATCH_PROMPT_KEY = "generate_choice_set_result_match";
    // ODD_ONE_OUT 전용 프롬프트 키 — 기준과 같은 결과 3개 + 다른 결과 1개(정답), SandboxValidator 3:1 판정과 짝 (#699)
    private static final String ODD_ONE_OUT_PROMPT_KEY = "generate_choice_set_odd_one_out";

    // 개념 문제 재시도 규칙: 재시도 불가는 AI fallback 실패 1개
    private static final ChoiceSetRetryRule CONCEPT_RETRY_RULE = new ChoiceSetRetryRule("choice-gen-concept",
            EnumSet.of(ErrorCode.AI_FALLBACK_FAILED),
            (run, errorCode, attempt) -> log.error("[choice-gen-concept] AI fallback 실패, 재시도 불가: attempt={}, questionUuid={}",
                    attempt, run.questionUuid()),
            (run, exception, attempt) -> log.warn("[choice-gen-concept] transient error, retrying: code={}, attempt={}/{}",
                    exception.getErrorCode(), attempt, MAX_ATTEMPTS));
    // SQL 문제 재시도 규칙: 재시도 불가 3개 (샌드박스 준비 실패, 기준 SQL 실패, AI fallback 실패)
    private static final ChoiceSetRetryRule STANDARD_RETRY_RULE = new ChoiceSetRetryRule("choice-gen",
            EnumSet.of(ErrorCode.SANDBOX_SETUP_FAILED, ErrorCode.SANDBOX_ANSWER_SQL_FAILED, ErrorCode.AI_FALLBACK_FAILED),
            (run, errorCode, attempt) -> log.error("[choice-gen] 재시도 불가 에러: code={}, attempt={}, questionUuid={}",
                    errorCode, attempt, run.questionUuid()),
            (run, exception, attempt) -> log.warn("[choice-gen] transient error, retrying: code={}, attempt={}/{}",
                    exception.getErrorCode(), attempt, MAX_ATTEMPTS, exception));
    // 결과 비교 문제 재시도 규칙: 재시도 불가 3개 (SQL 문제와 동일)
    private static final ChoiceSetRetryRule RESULT_MATCH_RETRY_RULE = new ChoiceSetRetryRule("choice-gen-result-match",
            EnumSet.of(ErrorCode.SANDBOX_SETUP_FAILED, ErrorCode.SANDBOX_ANSWER_SQL_FAILED, ErrorCode.AI_FALLBACK_FAILED),
            (run, errorCode, attempt) -> log.error("[choice-gen-result-match] 재시도 불가 에러: code={}, attempt={}",
                    errorCode, attempt),
            (run, exception, attempt) -> log.warn("[choice-gen-result-match] transient error, retrying: code={}, attempt={}/{}",
                    exception.getErrorCode(), attempt, MAX_ATTEMPTS));

    private final QuestionService questionService;
    private final PromptService promptService;
    private final AiGatewayClient aiGatewayClient;
    private final SandboxValidator sandboxValidator;
    private final ResultMatchChoiceValidator resultMatchChoiceValidator;
    private final ResultTableChoiceBuilder resultTableChoiceBuilder;
    private final ChoiceSetSaveService choiceSetSaveService;
    private final ChoiceSetGenerationRequestFactory requestFactory;
    private final ChoiceSetAttemptRunner attemptRunner;

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

        ChoiceSetGenerationRun run = new ChoiceSetGenerationRun(questionUuid, question, memberUuid, source, prompt);
        QuestionChoiceSet savedChoiceSet = attemptRunner.runAttempts(run, CONCEPT_RETRY_RULE, attempt -> attemptConcept(run, request, attempt));
        if (savedChoiceSet != null) {
            return savedChoiceSet;
        }
        throw attemptRunner.saveFailedAfterRetries(run, "concept questionUuid=" + questionUuid);
    }

    /**
     * 선택지 세트를 AI로 생성하고 샌드박스로 검증한다.
     * 최대 3회 재시도 후 실패 시 CustomException을 던진다 (검증 실패 세트는 저장하지 않음, #828)
     * <p>
     * MULTIPLE_CORRECT 실패 시 이전 시도에서 정답과 동일한 결과를 낸 오답 SQL을
     * 피드백으로 누적하여 다음 AI 요청에 포함한다.
     * 이를 통해 AI가 같은 SQL 동치(equivalence) 실수를 반복하는 것을 방지한다.
     */
    public QuestionChoiceSet generate(UUID questionUuid, UUID memberUuid, ChoiceSetSource source) {
        ChoiceSetGenerationRun run = startStandardRun(questionUuid, memberUuid, source);
        ChoiceSetRetryFeedback feedback = new ChoiceSetRetryFeedback(requestFactory.hasAnswerResultPlaceholder(run.prompt()));

        QuestionChoiceSet savedChoiceSet = attemptRunner.runAttempts(run, STANDARD_RETRY_RULE, attempt -> attemptStandard(run, feedback, attempt));
        if (savedChoiceSet != null) {
            return savedChoiceSet;
        }
        throw attemptRunner.saveFailedAfterRetries(run, "questionUuid=" + questionUuid + ", source=" + source);
    }

    /**
     * RESULT_MATCH 전용 (#828): AI 는 오해 SQL 후보만 쓰고, 보이는 결과 표는 전부 실제 실행 결과
     * 시도마다: 전용 프롬프트 요청 > 후보 실행·오답 모으기 > 3개 모이면 정답 표와 조립해 저장
     */
    public QuestionChoiceSet generateResultMatch(UUID questionUuid, UUID memberUuid, ChoiceSetSource source) {
        Question question = questionService.getQuestionEntity(questionUuid);
        PromptTemplate prompt = promptService.getActivePrompt(RESULT_MATCH_PROMPT_KEY);
        ChoiceSetGenerationRun run = new ChoiceSetGenerationRun(questionUuid, question, memberUuid, source, prompt);

        // schemaDdl·answerSql 없이는 실행 결과 표를 만들 수 없음
        if (question.getSchemaDdl() == null || question.getSchemaDdl().isBlank()) {
            throw new CustomException(ErrorCode.SANDBOX_SETUP_FAILED, "RESULT_MATCH는 schemaDdl이 필수입니다.");
        }
        if (question.getAnswerSql() == null || question.getAnswerSql().isBlank()) {
            throw new CustomException(ErrorCode.SANDBOX_ANSWER_SQL_FAILED, "RESULT_MATCH는 answerSql이 필수입니다.");
        }

        ChoiceSetRetryFeedback feedback = new ChoiceSetRetryFeedback(requestFactory.hasAnswerResultPlaceholder(run.prompt()));
        QuestionChoiceSet savedChoiceSet = attemptRunner.runAttempts(run, RESULT_MATCH_RETRY_RULE,
                attempt -> attemptResultMatch(run, feedback, attempt));
        if (savedChoiceSet != null) {
            return savedChoiceSet;
        }
        throw attemptRunner.saveFailedAfterRetries(run, "result-match questionUuid=" + questionUuid);
    }

    /**
     * 문제 정책 > 생성 경로 (#828): 개념형 > 개념 보기, 결과 표 > 결과형, 그 외 SQL 보기
     * 프리페치·관리자 재생성 공용 (정책과 다른 보기 세트가 만들어지지 않게)
     */
    public QuestionChoiceSet generateForQuestion(UUID questionUuid, UUID memberUuid, ChoiceSetSource source) {
        Question question = questionService.getQuestionEntity(questionUuid);
        if (question.getExecutionMode() == ExecutionMode.CONCEPT_ONLY) {
            return generateConcept(questionUuid, memberUuid, source);
        }
        if (question.getChoiceSetPolicy() == ChoiceSetPolicy.RESULT_MATCH) {
            return generateResultMatch(questionUuid, memberUuid, source);
        }
        return generate(questionUuid, memberUuid, source);
    }

    /** SQL 보기 정책 > 프롬프트 키 (ODD_ONE_OUT 은 정답 방향이 반대라 전용 프롬프트, 그 외 기본) */
    static String toStandardPromptKey(ChoiceSetPolicy policy) {
        return policy == ChoiceSetPolicy.ODD_ONE_OUT ? ODD_ONE_OUT_PROMPT_KEY : PROMPT_KEY;
    }

    /** 개념 문제 1회 시도: AI 호출 > is_correct 1개 확인 > 저장 (실패 시 null) */
    private QuestionChoiceSet attemptConcept(ChoiceSetGenerationRun run, GenerateChoiceSetRequest request, int attempt) {
        UUID questionUuid = run.questionUuid();
        log.debug("[choice-gen-concept] AI 호출 시작: attempt={}/{}, questionUuid={}", attempt, MAX_ATTEMPTS, questionUuid);
        GenerateChoiceSetResult aiResult = aiGatewayClient.generateChoiceSet(request);
        run.recordAiResult(aiResult);
        log.debug("[choice-gen-concept] AI 응답 수신: attempt={}, choiceCount={}, questionUuid={}",
                attempt, aiResult.choices().size(), questionUuid);

        // AI가 내려준 is_correct 집계 — 1개여야 유효
        long correctCount = aiResult.choices().stream()
                .filter(c -> Boolean.TRUE.equals(c.isCorrect()))
                .count();
        log.debug("[choice-gen-concept] is_correct 집계: correctCount={}, attempt={}, questionUuid={}",
                correctCount, attempt, questionUuid);

        if (correctCount == 1) {
            log.debug("[choice-gen-concept] 검증 통과, 저장 시작: attempt={}, questionUuid={}", attempt, questionUuid);
            return choiceSetSaveService.saveConceptSuccess(
                    run.question(), run.source(), run.memberUuid(), run.prompt(), aiResult, attempt);
        }

        ErrorCode errorCode = run.recordValidationFailure(correctCount);
        log.info("[choice-gen-concept] validation failed: code={}, attempt={}/{}, questionUuid={}",
                errorCode, attempt, MAX_ATTEMPTS, questionUuid);
        return null;
    }

    /** SQL 문제 실행 준비: 문제 조회 > 정책별 프롬프트 키 > 활성 프롬프트 */
    private ChoiceSetGenerationRun startStandardRun(UUID questionUuid, UUID memberUuid, ChoiceSetSource source) {
        Question question = questionService.getQuestionEntity(questionUuid);
        String promptKey = toStandardPromptKey(question.getChoiceSetPolicy());
        PromptTemplate prompt = promptService.getActivePrompt(promptKey);
        log.debug("[choice-gen] 요청 빌드 완료: questionUuid={}, promptKey={}", questionUuid, promptKey);
        return new ChoiceSetGenerationRun(questionUuid, question, memberUuid, source, prompt);
    }

    /** SQL 문제 1회 시도: 요청 빌드(피드백 포함) > AI 호출 > 샌드박스 검증 > 저장 또는 피드백 누적 (실패 시 null) */
    private QuestionChoiceSet attemptStandard(ChoiceSetGenerationRun run, ChoiceSetRetryFeedback feedback, int attempt) {
        Question question = run.question();
        UUID questionUuid = run.questionUuid();
        // 실행 실패(SANDBOX_ANSWER_SQL_FAILED)는 재시도 불가 처리로 실패 저장
        if (feedback.isExpectedResultPending()) {
            feedback.recordExpectedResult(resultMatchChoiceValidator.executeExpectedResult(question));
        }
        // 재시도마다 피드백(동치 SQL 목록, 직전 실행 결과)을 포함한 요청을 새로 빌드
        GenerateChoiceSetRequest request = requestFactory.buildStandardRequest(
                question, run.prompt(), feedback.equivalentSqls(), feedback.previousChoiceResultLines(), feedback.expectedResult());

        log.debug("[choice-gen] AI 호출 시작: attempt={}/{}, questionUuid={}, feedbackCount={}",
                attempt, MAX_ATTEMPTS, questionUuid, feedback.equivalentSqls().size());
        GenerateChoiceSetResult aiResult = aiGatewayClient.generateChoiceSet(request);
        run.recordAiResult(aiResult);
        log.debug("[choice-gen] AI 응답 수신: attempt={}, choiceCount={}, questionUuid={}",
                attempt, aiResult.choices().size(), questionUuid);

        log.debug("[choice-gen] Sandbox 검증 시작: attempt={}, questionUuid={}", attempt, questionUuid);
        // policy를 validator에 전달 — ODD_ONE_OUT 유형은 다른 검증 로직 적용
        ValidationReport report = sandboxValidator.validate(
                aiResult.choices(),
                question.getAnswerSql(),
                question.getSchemaDdl(),
                question.getSchemaSampleData(),
                question.getChoiceSetPolicy());
        log.debug("[choice-gen] Sandbox 검증 완료: attempt={}, correctCount={}, questionUuid={}",
                attempt, report.correctCount(), questionUuid);

        if (report.correctCount() == 1) {
            log.debug("[choice-gen] 검증 통과, 저장 시작: attempt={}, questionUuid={}", attempt, questionUuid);
            return choiceSetSaveService.saveSuccess(
                    question, run.source(), run.memberUuid(), run.prompt(), aiResult, report, attempt);
        }

        ErrorCode errorCode = run.recordValidationFailure(report.correctCount());
        log.info("[choice-gen] validation failed: code={}, attempt={}/{}, questionUuid={}",
                errorCode, attempt, MAX_ATTEMPTS, questionUuid);
        collectStandardFeedback(run, feedback, aiResult, report, attempt);
        return null;
    }

    /** 다음 시도 피드백 누적: MULTIPLE_CORRECT 동치 SQL, 직전 선택지별 실행 결과 (#720) */
    private void collectStandardFeedback(ChoiceSetGenerationRun run, ChoiceSetRetryFeedback feedback,
                                         GenerateChoiceSetResult aiResult, ValidationReport report, int attempt) {
        // MULTIPLE_CORRECT 실패 시 정답과 동치인 오답 SQL을 피드백 목록에 누적
        // 다음 시도에서 AI가 동일한 SQL을 생성하지 않도록 명시적으로 금지
        if (run.lastErrorCode() == ErrorCode.CHOICE_SET_VALIDATION_MULTIPLE_CORRECT) {
            requestFactory.collectEquivalentSqls(aiResult.choices(), report, feedback.equivalentSqls());
            log.info("[choice-gen] 동치 SQL 피드백 누적: count={}, attempt={}, questionUuid={}",
                    feedback.equivalentSqls().size(), attempt, run.questionUuid());
        }
        // 직전 실행 결과 피드백: ODD_ONE_OUT 결과만, AI_ONLY 기준과 같음/다름 표시 포함 (#720)
        boolean isOddOneOut = run.question().getChoiceSetPolicy() == ChoiceSetPolicy.ODD_ONE_OUT;
        feedback.replacePreviousChoiceResultLines(requestFactory.toChoiceResultLines(aiResult.choices(), report, !isOddOneOut));
    }

    /**
     * 결과 비교 문제 1회 시도 (#828): 요청(피드백 포함) > AI 보기 SQL > 실행해 쓸 만한 오답 모으기
     * 서로 다른 오답 3개가 모이면 정답 표(기준 SQL 결과)와 조립해 저장, 모자라면 null (모은 오답은 다음 시도로)
     */
    private QuestionChoiceSet attemptResultMatch(ChoiceSetGenerationRun run, ChoiceSetRetryFeedback feedback, int attempt) {
        Question question = run.question();
        if (feedback.isExpectedResultPending()) {
            feedback.recordExpectedResult(resultMatchChoiceValidator.executeExpectedResult(question));
        }
        GenerateChoiceSetRequest request = requestFactory.buildStandardRequest(
                question, run.prompt(), feedback.equivalentSqls(), feedback.previousChoiceResultLines(), feedback.expectedResult());
        log.debug("[choice-gen-result-match] AI 호출 시작: attempt={}/{}, questionUuid={}", attempt, MAX_ATTEMPTS, run.questionUuid());
        GenerateChoiceSetResult aiResult = aiGatewayClient.generateChoiceSet(request);
        run.recordAiResult(aiResult);

        ResultTableChoiceBuilder.ScreenedAttempt screened =
                resultTableChoiceBuilder.screenAttempt(question, aiResult.choices(), feedback.collectedWrongTables());
        feedback.collectedWrongTables().addAll(screened.newWrongTables());
        feedback.keepEmptyWrongTableIfAbsent(screened.emptyWrongTable());
        int collectedCount = feedback.collectedWrongTables().size();
        List<ResultTableChoiceBuilder.WrongTable> wrongTables = pickWrongTables(feedback, attempt);
        if (wrongTables != null) {
            // 빈 결과 예비 사용 여부 (예비 없으면 false, 불변 리스트 contains(null) 예외 방지)
            boolean usesEmptyWrongTable = feedback.emptyWrongTable() != null && wrongTables.contains(feedback.emptyWrongTable());
            log.debug("[choice-gen-result-match] 오답 확보, 저장: collected={}, usesEmpty={}, attempt={}",
                    collectedCount, usesEmptyWrongTable, attempt);
            ResultTableChoiceBuilder.AssembledChoices assembled = resultTableChoiceBuilder.assemble(
                    screened.correctTableJson(), wrongTables);
            GenerateChoiceSetResult tableResult = new GenerateChoiceSetResult(assembled.choices(), aiResult.metadata());
            return choiceSetSaveService.saveResultMatch(
                    question, run.source(), run.memberUuid(), run.prompt(), tableResult, assembled.report(), attempt);
        }

        // 모자람: 정답과 같은 오답 SQL 은 동치 피드백, 보기별 실제 결과·버린 이유·모은 개수를 다음 요청에
        run.recordErrorCode(ErrorCode.CHOICE_SET_GENERATION_FAILED);
        log.info("[choice-gen-result-match] wrong tables short: collected={}, discards={}, attempt={}/{}, questionUuid={}",
                collectedCount, screened.discardByKey(), attempt, MAX_ATTEMPTS, run.questionUuid());
        requestFactory.collectEquivalentSqls(aiResult.choices(), screened.report(), feedback.equivalentSqls());
        List<String> resultLines = new ArrayList<>(
                requestFactory.toChoiceResultLines(aiResult.choices(), screened.report(), true));
        screened.discardByKey().forEach((key, discard) -> resultLines.add(key + " 버림: " + discard.retryFeedback()));
        // 이미 모은 오답 결과 (이 결과를 다시 내면 중복으로 버려짐)
        // 중괄호는 대괄호로 (프롬프트 {placeholder} 치환 오염 방지, serializeExecuteResult 와 같은 규칙)
        feedback.collectedWrongTables().forEach(wrongTable -> resultLines.add("확보한 오답 결과 (다시 내지 말 것): "
                + wrongTable.tableJson().replace("{", "[").replace("}", "]")));
        resultLines.add("지금까지 쓸 수 있는 오답 결과 " + collectedCount + "개 확보, " + (ResultTableChoiceBuilder.WRONG_CHOICE_COUNT - collectedCount)
                + "개 더 필요. 위 결과들과 모두 다른 결과가 나오는 새 오해로 후보 SQL 4개를 다시 만들 것.");
        feedback.replacePreviousChoiceResultLines(resultLines);
        return null;
    }

    /**
     * 조립할 오답 3개: 빈 결과 아닌 오답 3개 > (마지막 시도만) 빈 결과 아닌 2개 + 빈 결과 예비 1개 > 모자라면 null
     */
    private static List<ResultTableChoiceBuilder.WrongTable> pickWrongTables(ChoiceSetRetryFeedback feedback, int attempt) {
        List<ResultTableChoiceBuilder.WrongTable> collected = feedback.collectedWrongTables();
        int wrongChoiceCount = ResultTableChoiceBuilder.WRONG_CHOICE_COUNT;
        if (collected.size() >= wrongChoiceCount) {
            return List.copyOf(collected.subList(0, wrongChoiceCount));
        }
        boolean isLastAttempt = attempt >= MAX_ATTEMPTS;
        if (isLastAttempt && collected.size() == wrongChoiceCount - 1 && feedback.emptyWrongTable() != null) {
            List<ResultTableChoiceBuilder.WrongTable> withEmpty = new ArrayList<>(collected);
            withEmpty.add(feedback.emptyWrongTable());
            return withEmpty;
        }
        return null;
    }
}
