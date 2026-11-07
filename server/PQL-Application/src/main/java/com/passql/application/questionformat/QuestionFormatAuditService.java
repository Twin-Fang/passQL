package com.passql.application.questionformat;

import com.passql.application.questionformat.dto.QuestionFormatAuditReport;
import com.passql.application.questionformat.dto.QuestionFormatAuditRow;
import com.passql.application.questionformat.dto.QuestionFormatReasonCount;
import com.passql.common.util.MarkdownTextStripper;
import com.passql.common.util.TextPreview;
import com.passql.meta.entity.ConceptCheckChoice;
import com.passql.meta.entity.ConceptCheckQuestion;
import com.passql.meta.entity.ConceptDoc;
import com.passql.meta.repository.ConceptCheckChoiceRepository;
import com.passql.meta.repository.ConceptCheckQuestionRepository;
import com.passql.meta.repository.ConceptDocRepository;
import com.passql.question.constant.ChoiceKind;
import com.passql.question.constant.QuestionFormatViolationReason;
import com.passql.question.dto.QuestionFormatChoice;
import com.passql.question.dto.QuestionFormatInput;
import com.passql.question.dto.QuestionFormatViolation;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.service.QuestionFormatRule;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 형식 일괄 점검 (#905): 활성 문제·공유 세트 보기·세트 해설·개념 글·개념 확인 문제를 QuestionFormatRule 로 검사 > 사유별 건수 + 위반 줄
 * 읽기만 함 (정리는 QuestionFormatAutoFixService)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class QuestionFormatAuditService {

    // 화면에 그릴 위반 줄 상한 (사유 필터로 좁혀 봄)
    static final int MAX_SHOWN_ROW_COUNT = 1000;
    private static final String TARGET_QUESTION = "문제";
    private static final String TARGET_CHOICE_SET = "보기 세트";
    private static final String TARGET_CONCEPT_DOC = "개념 글";
    private static final String TARGET_CONCEPT_CHECK = "개념 확인 문제";

    private final QuestionFormatScanScopeLoader scopeLoader;
    private final ConceptDocRepository conceptDocRepository;
    private final ConceptCheckQuestionRepository conceptCheckQuestionRepository;
    private final ConceptCheckChoiceRepository conceptCheckChoiceRepository;

    /** 전체 점검 > 보고서 (reasonFilterOrNull 이면 그 사유 줄만, 건수 표는 전체) */
    public QuestionFormatAuditReport audit(QuestionFormatViolationReason reasonFilterOrNull) {
        QuestionFormatScanScope scope = scopeLoader.loadActiveQuestions();
        List<QuestionFormatAuditRow> rows = new ArrayList<>();
        Set<UUID> violatingQuestionUuids = new HashSet<>();
        for (Question question : scope.questions()) {
            int rowCountBefore = rows.size();
            addQuestionRows(question, scope, rows);
            if (rows.size() > rowCountBefore) violatingQuestionUuids.add(question.getQuestionUuid());
        }
        List<ConceptDoc> conceptDocs = conceptDocRepository.findAll().stream()
                .filter(doc -> Boolean.TRUE.equals(doc.getIsActive())).toList();
        conceptDocs.forEach(doc -> addConceptDocRows(doc, rows));
        addConceptCheckRows(rows);

        List<QuestionFormatAuditRow> filteredRows = rows.stream()
                .filter(row -> reasonFilterOrNull == null || row.reason() == reasonFilterOrNull)
                .toList();
        return new QuestionFormatAuditReport(scope.questions().size(), scope.choiceSetCount(), conceptDocs.size(),
                violatingQuestionUuids.size(), toReasonCounts(rows), filteredRows.size(),
                filteredRows.stream().limit(MAX_SHOWN_ROW_COUNT).toList());
    }

    // 문제 필드 + 공유 세트 보기·세트 해설
    private void addQuestionRows(Question question, QuestionFormatScanScope scope, List<QuestionFormatAuditRow> rows) {
        String stemPreview = toPreview(question.getStem());
        String mockExamLabel = scope.mockExamLabelOf(question.getQuestionUuid());
        String questionLink = "/admin/questions/" + question.getQuestionUuid();
        QuestionFormatRule.check(QuestionFormatInput.from(question, List.of())).violations().forEach(violation ->
                rows.add(toRow(TARGET_QUESTION, question.getQuestionUuid(), stemPreview, questionLink, mockExamLabel,
                        violation, true)));

        for (QuestionChoiceSet choiceSet : scope.setsOf(question.getQuestionUuid())) {
            String setLink = "/admin/choice-sets/" + choiceSet.getChoiceSetUuid();
            List<QuestionFormatViolation> violations = new ArrayList<>();
            for (QuestionChoiceSetItem item : scope.itemsOf(choiceSet.getChoiceSetUuid())) {
                violations.addAll(findItemViolations(item));
            }
            violations.addAll(QuestionFormatRule.findForbiddenPunctuationViolations(choiceSet.getExplanationJson(), "세트 해설"));
            violations.forEach(violation -> rows.add(toRow(TARGET_CHOICE_SET, choiceSet.getChoiceSetUuid(), stemPreview,
                    setLink, mockExamLabel, violation, true)));
        }
    }

    // 보기 1개: 본문·근거 규칙 + 해설(근거와 다를 때만, 같으면 중복 줄), SQL·결과 표 본문 줄표·가운뎃점은 손으로
    private List<QuestionFormatViolation> findItemViolations(QuestionChoiceSetItem item) {
        String location = "보기 " + item.getChoiceKey();
        List<QuestionFormatViolation> violations = new ArrayList<>();
        for (QuestionFormatViolation violation : QuestionFormatRule.findChoiceViolations(QuestionFormatChoice.from(item))) {
            boolean isNonTextBodyDash = violation.reason() == QuestionFormatViolationReason.FORBIDDEN_PUNCTUATION
                    && violation.location().equals(location) && item.getKind() != ChoiceKind.TEXT;
            violations.add(isNonTextBodyDash ? new QuestionFormatViolation(violation.reason(), violation.location(),
                    violation.detail(), false) : violation);
        }
        if (!Objects.equals(item.getExplanation(), item.getRationale())) {
            violations.addAll(QuestionFormatRule.findForbiddenPunctuationViolations(item.getExplanation(), location + " 해설"));
        }
        return violations;
    }

    // 개념 글 3필드 (제목·핵심·자세히), 원본이 레포라 자동 정리 안 함
    private void addConceptDocRows(ConceptDoc doc, List<QuestionFormatAuditRow> rows) {
        String link = "/admin/concepts/learning/" + doc.getConceptTagUuid() + "/preview";
        Map<String, String> textByLocation = Map.of("개념 제목", Objects.toString(doc.getTitle(), ""),
                "개념 핵심", Objects.toString(doc.getCoreMd(), ""), "개념 자세히", Objects.toString(doc.getDetailMd(), ""));
        textByLocation.forEach((location, text) -> QuestionFormatRule.findConceptArticleDashViolations(text, location)
                .forEach(violation -> rows.add(toRow(TARGET_CONCEPT_DOC, doc.getConceptDocUuid(), doc.getTitle(), link,
                        null, violation, false))));
    }

    // 개념 확인 문제: 지문·지문 SQL·해설 + 보기 본문·이유 줄표·가운뎃점
    private void addConceptCheckRows(List<QuestionFormatAuditRow> rows) {
        List<ConceptCheckQuestion> checkQuestions = conceptCheckQuestionRepository.findAll();
        Map<UUID, List<ConceptCheckChoice>> choicesByQuestionUuid = conceptCheckChoiceRepository
                .findByConceptCheckQuestionUuidInOrderBySortOrderAsc(
                        checkQuestions.stream().map(ConceptCheckQuestion::getConceptCheckQuestionUuid).toList())
                .stream().collect(Collectors.groupingBy(ConceptCheckChoice::getConceptCheckQuestionUuid));
        for (ConceptCheckQuestion checkQuestion : checkQuestions) {
            String link = "/admin/concepts/learning/" + checkQuestion.getConceptTagUuid() + "/preview";
            List<QuestionFormatViolation> violations = new ArrayList<>();
            violations.addAll(QuestionFormatRule.findForbiddenPunctuationViolations(checkQuestion.getStem(), "확인 문제 지문"));
            violations.addAll(QuestionFormatRule.findForbiddenPunctuationViolations(checkQuestion.getStemSql(), "확인 문제 SQL"));
            violations.addAll(QuestionFormatRule.findForbiddenPunctuationViolations(checkQuestion.getExplanation(), "확인 문제 해설"));
            for (ConceptCheckChoice choice : choicesByQuestionUuid.getOrDefault(checkQuestion.getConceptCheckQuestionUuid(), List.of())) {
                violations.addAll(QuestionFormatRule.findForbiddenPunctuationViolations(choice.getBody(), "확인 보기 " + choice.getChoiceKey()));
                violations.addAll(QuestionFormatRule.findForbiddenPunctuationViolations(choice.getRationale(),
                        "확인 보기 " + choice.getChoiceKey() + " 이유"));
            }
            violations.forEach(violation -> rows.add(toRow(TARGET_CONCEPT_CHECK, checkQuestion.getConceptCheckQuestionUuid(),
                    toPreview(checkQuestion.getStem()), link, null, violation, false)));
        }
    }

    private QuestionFormatAuditRow toRow(String targetTypeLabel, UUID targetUuid, String preview, String linkPath,
                                         String mockExamLabel, QuestionFormatViolation violation, boolean isFixableTarget) {
        return new QuestionFormatAuditRow(targetTypeLabel, targetUuid, preview, linkPath, mockExamLabel,
                violation.location(), violation.reason(), violation.detail(),
                isFixableTarget && Boolean.TRUE.equals(violation.isAutoFixable()));
    }

    // 사유 순서(enum 순)대로 건수, 0건 사유도 표에 남김
    private List<QuestionFormatReasonCount> toReasonCounts(List<QuestionFormatAuditRow> rows) {
        return Arrays.stream(QuestionFormatViolationReason.values())
                .map(reason -> new QuestionFormatReasonCount(reason,
                        rows.stream().filter(row -> row.reason() == reason).count(),
                        rows.stream().filter(row -> row.reason() == reason && row.isAutoFixable()).count()))
                .toList();
    }

    private static String toPreview(String markdown) {
        return TextPreview.truncateWithEllipsis(MarkdownTextStripper.toPlainText(markdown), TextPreview.FORMAT_AUDIT_STEM_LENGTH);
    }
}
