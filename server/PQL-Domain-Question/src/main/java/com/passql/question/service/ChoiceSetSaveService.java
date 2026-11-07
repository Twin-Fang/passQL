package com.passql.question.service;

import com.passql.ai.dto.GeneratedChoiceDto;
import com.passql.ai.dto.GenerateChoiceSetResult;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.PromptTemplate;
import com.passql.question.constant.ChoiceKind;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.dto.QuestionFormatChoice;
import com.passql.question.dto.QuestionFormatViolation;
import com.passql.question.dto.ValidationReport;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.event.ChoiceSetReadyEvent;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 선택지 세트·아이템 저장 전용 서비스.
 * <p>
 * ChoiceSetGenerationService 내부에서 self-invocation으로 @Transactional이 무시되는 문제를 방지하기 위해
 * 별도 빈으로 분리. Spring AOP 프록시를 통해 정상적으로 트랜잭션이 적용된다.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ChoiceSetSaveService {

    private final QuestionChoiceSetRepository choiceSetRepository;
    private final QuestionChoiceSetItemRepository choiceSetItemRepository;
    private final ApplicationEventPublisher eventPublisher;

    /**
     * EXECUTABLE 선택지 세트 성공 저장 — 샌드박스 검증 결과(ValidationReport) 기반 is_correct 적용.
     */
    @Transactional
    public QuestionChoiceSet saveSuccess(
            Question question, ChoiceSetSource source, UUID memberUuid,
            PromptTemplate prompt, GenerateChoiceSetResult result,
            ValidationReport report, int attempts) {

        QuestionChoiceSet set = QuestionChoiceSet.builder()
                .questionUuid(question.getQuestionUuid())
                .source(source)
                .status(ChoiceSetStatus.OK)
                .generatedForMemberUuid(memberUuid)
                .promptTemplateUuid(prompt.getPromptTemplateUuid())
                .modelName(prompt.getModel())
                .temperature(prompt.getTemperature())
                .maxTokens(prompt.getMaxTokens())
                .generationAttempts(attempts)
                .sandboxValidationPassed(true)
                .isReusable(false)
                .totalElapsedMs(result.metadata() != null ? result.metadata().elapsedMs() : 0)
                .build();
        set = choiceSetRepository.saveAndFlush(set);

        List<GeneratedChoiceDto> choices = result.choices();
        for (int i = 0; i < choices.size(); i++) {
            GeneratedChoiceDto choice = toFormattedChoice(question, choices.get(i), ChoiceKind.SQL, false);
            // 샌드박스 결과 기반 is_correct 덮어쓰기
            boolean isCorrectByExecution = report.items().get(i).matchesExpected();
            QuestionChoiceSetItem item = QuestionChoiceSetItem.builder()
                    .choiceSetUuid(set.getChoiceSetUuid())
                    .choiceKey(choice.key())
                    .sortOrder(i)
                    .kind(ChoiceKind.SQL)
                    .body(choice.body())
                    .isCorrect(isCorrectByExecution)
                    .rationale(choice.rationale())
                    .build();
            choiceSetItemRepository.save(item);
        }

        log.info("[choice-gen] success: questionUuid={}, attempts={}, setUuid={}",
                question.getQuestionUuid(), attempts, set.getChoiceSetUuid());
        // 커밋 후 선택지별 AI 해설 미리 생성 (#496)
        eventPublisher.publishEvent(new ChoiceSetReadyEvent(set.getChoiceSetUuid()));
        return set;
    }

    /**
     * CONCEPT_ONLY 선택지 세트 성공 저장 — AI의 is_correct 직접 사용 (샌드박스 없음).
     */
    @Transactional
    public QuestionChoiceSet saveConceptSuccess(
            Question question, ChoiceSetSource source, UUID memberUuid,
            PromptTemplate prompt, GenerateChoiceSetResult result, int attempts) {

        QuestionChoiceSet set = QuestionChoiceSet.builder()
                .questionUuid(question.getQuestionUuid())
                .source(source)
                .status(ChoiceSetStatus.OK)
                .generatedForMemberUuid(memberUuid)
                .promptTemplateUuid(prompt.getPromptTemplateUuid())
                .modelName(prompt.getModel())
                .temperature(prompt.getTemperature())
                .maxTokens(prompt.getMaxTokens())
                .generationAttempts(attempts)
                .sandboxValidationPassed(false) // 개념 문제는 샌드박스 미사용
                .isReusable(false)
                .totalElapsedMs(result.metadata() != null ? result.metadata().elapsedMs() : 0)
                .build();
        set = choiceSetRepository.saveAndFlush(set);

        List<GeneratedChoiceDto> choices = result.choices();
        for (int i = 0; i < choices.size(); i++) {
            GeneratedChoiceDto choice = toFormattedChoice(question, choices.get(i), ChoiceKind.TEXT, true);
            // AI가 직접 is_correct를 판별 — 샌드박스 검증 없음
            QuestionChoiceSetItem item = QuestionChoiceSetItem.builder()
                    .choiceSetUuid(set.getChoiceSetUuid())
                    .choiceKey(choice.key())
                    .sortOrder(i)
                    .kind(ChoiceKind.TEXT)
                    .body(choice.body())
                    .isCorrect(choice.isCorrect())
                    .rationale(choice.rationale())
                    .build();
            choiceSetItemRepository.save(item);
        }

        log.info("[choice-gen-concept] success: questionUuid={}, attempts={}, setUuid={}",
                question.getQuestionUuid(), attempts, set.getChoiceSetUuid());
        // 커밋 후 선택지별 AI 해설 미리 생성 (#496)
        eventPublisher.publishEvent(new ChoiceSetReadyEvent(set.getChoiceSetUuid()));
        return set;
    }

    /**
     * RESULT_MATCH 선택지 세트 성공 저장 (#828)
     * kind=TEXT(실행 결과 표 JSON), is_correct=실행 판정(ValidationReport), 보기 SQL 4개 실행·판정을 통과한 세트만
     */
    @Transactional
    public QuestionChoiceSet saveResultMatch(
            Question question, ChoiceSetSource source, UUID memberUuid,
            PromptTemplate prompt, GenerateChoiceSetResult result,
            ValidationReport report, int attempts) {

        QuestionChoiceSet set = QuestionChoiceSet.builder()
                .questionUuid(question.getQuestionUuid())
                .source(source)
                .status(ChoiceSetStatus.OK)
                .generatedForMemberUuid(memberUuid)
                .promptTemplateUuid(prompt.getPromptTemplateUuid())
                .modelName(prompt.getModel())
                .temperature(prompt.getTemperature())
                .maxTokens(prompt.getMaxTokens())
                .generationAttempts(attempts)
                .sandboxValidationPassed(true) // 보기 SQL 실제 실행 결과 + 정답 1개·오답 서로 다름 판정 통과
                .isReusable(false)
                .totalElapsedMs(result.metadata() != null ? result.metadata().elapsedMs() : 0)
                .build();
        set = choiceSetRepository.saveAndFlush(set);

        // key 기반 매핑 — 인덱스 순서 의존 제거
        Map<String, Boolean> correctMap = report.items().stream()
                .collect(Collectors.toMap(
                        ValidationReport.ChoiceValidation::key,
                        ValidationReport.ChoiceValidation::matchesExpected));

        List<GeneratedChoiceDto> choices = result.choices();
        for (int i = 0; i < choices.size(); i++) {
            // 본문은 실행 결과 표 JSON > 근거만 정리
            GeneratedChoiceDto choice = toFormattedChoice(question, choices.get(i), ChoiceKind.TEXT, false);
            // is_correct는 AI 판단이 아닌 실행 판정 결과로 덮어쓰기
            boolean isCorrectByExecution = correctMap.getOrDefault(choice.key(), false);
            QuestionChoiceSetItem item = QuestionChoiceSetItem.builder()
                    .choiceSetUuid(set.getChoiceSetUuid())
                    .choiceKey(choice.key())
                    .sortOrder(i)
                    .kind(ChoiceKind.TEXT)   // RESULT_MATCH는 항상 TEXT
                    .body(choice.body())          // 실행 결과 표 JSON 배열 문자열
                    .isCorrect(isCorrectByExecution)
                    .rationale(choice.rationale())
                    .build();
            choiceSetItemRepository.save(item);
        }

        log.info("[choice-gen-result-match] success: questionUuid={}, attempts={}, setUuid={}",
                question.getQuestionUuid(), attempts, set.getChoiceSetUuid());
        // 커밋 후 선택지별 AI 해설 미리 생성 (#496)
        eventPublisher.publishEvent(new ChoiceSetReadyEvent(set.getChoiceSetUuid()));
        return set;
    }

    /**
     * 생성 보기 저장 전 형식 정리 (#905): 줄표·가운뎃점 > ForbiddenPunctuationCleaner (근거 전부, 본문은 글 보기만), 남은 위반은 기록만
     * SQL·결과 표 본문은 실행 검증본이라 바꾸지 않음, 거부하지 않는 이유: 지시문 반영 전 생성 실패가 회원 풀이를 막지 않게
     */
    private GeneratedChoiceDto toFormattedChoice(Question question, GeneratedChoiceDto choice, ChoiceKind bodyKind,
                                                 boolean isBodyCleanable) {
        boolean isSqlBody = bodyKind == ChoiceKind.SQL;
        GeneratedChoiceDto formatted = new GeneratedChoiceDto(choice.key(),
                isBodyCleanable ? ForbiddenPunctuationCleaner.clean(choice.body()) : choice.body(),
                choice.isCorrect(), ForbiddenPunctuationCleaner.clean(choice.rationale()));
        List<QuestionFormatViolation> remainingViolations = QuestionFormatRule.findChoiceViolations(
                new QuestionFormatChoice(formatted.key(), isSqlBody, formatted.body(), formatted.rationale()));
        if (!remainingViolations.isEmpty()) {
            log.warn("[choice-gen format] remaining violations : questionUuid={}, choiceKey={}, reasons={}",
                    question.getQuestionUuid(), formatted.key(),
                    remainingViolations.stream().map(violation -> violation.reason().name()).distinct().toList());
        }
        return formatted;
    }

    /**
     * 선택지 세트 실패 저장.
     */
    @Transactional
    public void saveFailed(
            Question question, ChoiceSetSource source, UUID memberUuid,
            PromptTemplate prompt, GenerateChoiceSetResult result,
            int attempts, ErrorCode errorCode) {

        QuestionChoiceSet set = QuestionChoiceSet.builder()
                .questionUuid(question.getQuestionUuid())
                .source(source)
                .status(ChoiceSetStatus.FAILED)
                .generatedForMemberUuid(memberUuid)
                .promptTemplateUuid(prompt.getPromptTemplateUuid())
                .modelName(prompt.getModel())
                .temperature(prompt.getTemperature())
                .maxTokens(prompt.getMaxTokens())
                .generationAttempts(attempts)
                .sandboxValidationPassed(false)
                .isReusable(false)
                .build();
        choiceSetRepository.save(set);

        log.warn("[choice-gen] failed: questionUuid={}, attempts={}, errorCode={}",
                question.getQuestionUuid(), attempts, errorCode);
    }
}
