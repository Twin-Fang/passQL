package com.passql.question.service;

import com.passql.ai.dto.GeneratedChoiceDto;
import com.passql.meta.service.PromptService;
import com.passql.question.constant.ChoiceKind;
import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.dto.ChoiceSetIntegrityAuditPage;
import com.passql.question.dto.ChoiceSetIntegrityAuditPage.AuditItem;
import com.passql.question.dto.ChoiceSetIntegrityAuditPage.Verdict;
import com.passql.question.dto.ExecuteResult;
import com.passql.question.dto.ValidationReport;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import com.passql.question.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * 선택지 세트 전수 검증 (#828): 노출 중(OK) 세트를 샌드박스로 다시 채점, 읽기 전용(내리기는 관리자 일괄 비활성화)
 * 판정 기준: SQL 보기 재실행 정답 1개·표시 정답 일치, 결과 표 보기 정답 표 일치·중복·옛 방식(AI가 지은 표), 정책과 다른 보기 종류
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ChoiceSetIntegrityAuditService {

    // 옛 결과 표 생성 프롬프트: 키 + 이 버전 이하는 오답 표를 AI가 직접 써서 실제 실행 결과인지 확인할 수 없음 (#828 이전)
    static final String LEGACY_RESULT_TABLE_PROMPT_KEY = "generate_choice_set_result_match";
    static final int LEGACY_RESULT_TABLE_PROMPT_MAX_VERSION = 2;
    // 한 번에 검사하는 세트 수 상한 (세트마다 임시 샌드박스 1개)
    private static final int MAX_PAGE_SIZE = 50;

    private final QuestionChoiceSetRepository choiceSetRepository;
    private final QuestionChoiceSetItemRepository choiceSetItemRepository;
    private final QuestionRepository questionRepository;
    private final PromptService promptService;
    private final SandboxValidator sandboxValidator;
    private final ResultMatchChoiceValidator resultMatchChoiceValidator;

    /**
     * 노출 중 세트 1페이지 검사 (생성 순, 판정별 개수 + 정상 아닌 세트 목록)
     */
    public ChoiceSetIntegrityAuditPage auditPage(int page, int size) {
        int pageSize = Math.max(1, Math.min(size, MAX_PAGE_SIZE));
        Page<QuestionChoiceSet> choiceSets = choiceSetRepository.findByStatus(ChoiceSetStatus.OK,
                PageRequest.of(Math.max(0, page), pageSize, Sort.by("createdAt").ascending()));
        Map<Verdict, Integer> countByVerdict = new EnumMap<>(Verdict.class);
        List<AuditItem> problemItems = new ArrayList<>();
        for (QuestionChoiceSet choiceSet : choiceSets) {
            AuditItem item = auditChoiceSet(choiceSet);
            countByVerdict.merge(item.verdict(), 1, Integer::sum);
            if (item.verdict() != Verdict.VALID) {
                problemItems.add(item);
            }
        }
        return new ChoiceSetIntegrityAuditPage(choiceSets.getNumber(), pageSize, choiceSets.getTotalElements(),
                choiceSets.hasNext(), countByVerdict, problemItems);
    }

    /** 세트 1개 판정: 문제·보기 조회 > 검사 대상 구분 > 결과 표 / SQL 보기 재채점 (샌드박스 오류는 ERROR, 내리지 않음) */
    AuditItem auditChoiceSet(QuestionChoiceSet choiceSet) {
        Question question = questionRepository.findById(choiceSet.getQuestionUuid()).orElse(null);
        List<QuestionChoiceSetItem> items = choiceSetItemRepository.findByChoiceSetUuidOrderBySortOrderAsc(
                choiceSet.getChoiceSetUuid());
        if (question == null || items.isEmpty()) {
            return toItem(choiceSet, question, Verdict.SKIPPED, "문제 또는 보기 없음");
        }
        boolean isResultTable = question.getChoiceSetPolicy() == ChoiceSetPolicy.RESULT_MATCH;
        boolean isAllSql = items.stream().allMatch(item -> item.getKind() == ChoiceKind.SQL);
        // 개념형·글 보기: 실행으로 정답을 확인할 수 없음
        if (question.getExecutionMode() == ExecutionMode.CONCEPT_ONLY || (!isResultTable && !isAllSql)) {
            return toItem(choiceSet, question, Verdict.SKIPPED, "개념형·글 보기 (실행 검증 대상 아님)");
        }
        try {
            return isResultTable
                    ? auditResultTable(choiceSet, question, items, isAllSql)
                    : auditSqlChoices(choiceSet, question, items);
        } catch (RuntimeException e) {
            log.warn("[choice audit] sandbox failed : choiceSet={}, reason={}", choiceSet.getChoiceSetUuid(),
                    SandboxExecutor.toAdminFailureReason(e));
            return toItem(choiceSet, question, Verdict.ERROR, SandboxExecutor.toAdminFailureReason(e));
        }
    }

    /** SQL 보기: 재실행 정답 정확히 1개 + 표시된 정답 key 와 같은지 */
    private AuditItem auditSqlChoices(QuestionChoiceSet choiceSet, Question question, List<QuestionChoiceSetItem> items) {
        ValidationReport report = sandboxValidator.validate(toChoiceDtos(items), question.getAnswerSql(),
                question.getSchemaDdl(), question.getSchemaSampleData(), question.getChoiceSetPolicy());
        if (report.correctCount() != 1) {
            return toItem(choiceSet, question, Verdict.WRONG_CORRECT_COUNT, "재실행 정답 " + report.correctCount() + "개");
        }
        return compareCorrectKey(choiceSet, question, items, report);
    }

    /**
     * 결과 표 보기: 정책과 다른 SQL 보기 > 옛 방식(AI가 지은 표) > 정답 표 1개·표시 일치 > 중복 표
     */
    private AuditItem auditResultTable(QuestionChoiceSet choiceSet, Question question,
                                       List<QuestionChoiceSetItem> items, boolean isAllSql) {
        if (isAllSql) {
            return toItem(choiceSet, question, Verdict.POLICY_KIND_MISMATCH, "결과 표 문제에 SQL 보기 세트");
        }
        if (!choiceSet.getSource().isCurated() && isLegacyResultTablePrompt(choiceSet)) {
            return toItem(choiceSet, question, Verdict.FABRICATED_RESULT_TABLE, "오답 표를 AI가 직접 쓴 옛 방식 세트");
        }
        ExecuteResult expected = resultMatchChoiceValidator.executeExpectedResult(question);
        ValidationReport report = resultMatchChoiceValidator.validate(toChoiceDtos(items), expected);
        if (report.correctCount() != 1) {
            return toItem(choiceSet, question, Verdict.WRONG_CORRECT_COUNT, "정답 SQL 결과와 같은 표 " + report.correctCount() + "개");
        }
        AuditItem correctKeyCheck = compareCorrectKey(choiceSet, question, items, report);
        if (correctKeyCheck.verdict() != Verdict.VALID) {
            return correctKeyCheck;
        }
        String duplicateBody = ChoiceBodyDuplicateFinder.findDuplicateBody(
                items.stream().map(QuestionChoiceSetItem::getBody).toList());
        if (duplicateBody != null) {
            return toItem(choiceSet, question, Verdict.WEAK_DISTRACTOR, "같은 결과 표 보기 중복");
        }
        return toItem(choiceSet, question, Verdict.VALID, null);
    }

    /** 재채점 정답 key <-> 저장된 정답 표시 key */
    private AuditItem compareCorrectKey(QuestionChoiceSet choiceSet, Question question,
                                        List<QuestionChoiceSetItem> items, ValidationReport report) {
        String executedCorrectKey = report.items().stream()
                .filter(ValidationReport.ChoiceValidation::matchesExpected)
                .map(ValidationReport.ChoiceValidation::key)
                .findFirst().orElse(null);
        List<String> markedCorrectKeys = items.stream()
                .filter(item -> Boolean.TRUE.equals(item.getIsCorrect()))
                .map(QuestionChoiceSetItem::getChoiceKey)
                .toList();
        if (markedCorrectKeys.size() != 1 || !Objects.equals(markedCorrectKeys.get(0), executedCorrectKey)) {
            return toItem(choiceSet, question, Verdict.CORRECT_MARK_MISMATCH,
                    "재채점 정답 " + executedCorrectKey + " <-> 표시 정답 " + markedCorrectKeys);
        }
        return toItem(choiceSet, question, Verdict.VALID, null);
    }

    private boolean isLegacyResultTablePrompt(QuestionChoiceSet choiceSet) {
        if (choiceSet.getPromptTemplateUuid() == null) {
            return false;
        }
        return promptService.findById(choiceSet.getPromptTemplateUuid())
                .map(prompt -> LEGACY_RESULT_TABLE_PROMPT_KEY.equals(prompt.getKeyName())
                        && prompt.getVersion() <= LEGACY_RESULT_TABLE_PROMPT_MAX_VERSION)
                .orElse(false);
    }

    private static List<GeneratedChoiceDto> toChoiceDtos(List<QuestionChoiceSetItem> items) {
        return items.stream()
                .map(item -> new GeneratedChoiceDto(item.getChoiceKey(), item.getBody(),
                        Boolean.TRUE.equals(item.getIsCorrect()), item.getRationale()))
                .toList();
    }

    private static AuditItem toItem(QuestionChoiceSet choiceSet, Question question, Verdict verdict, String detail) {
        return new AuditItem(choiceSet.getChoiceSetUuid(), choiceSet.getQuestionUuid(),
                question != null ? question.getChoiceSetPolicy() : null,
                choiceSet.getSource(), choiceSet.getCreatedAt(), verdict, detail);
    }
}
