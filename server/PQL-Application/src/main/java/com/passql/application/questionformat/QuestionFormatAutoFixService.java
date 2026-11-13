package com.passql.application.questionformat;

import com.passql.application.questionformat.dto.QuestionFormatFixApplyRequest;
import com.passql.application.questionformat.dto.QuestionFormatFixApplyResult;
import com.passql.application.questionformat.dto.QuestionFormatFixPreview;
import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.util.MarkdownTextStripper;
import com.passql.common.util.TextPreview;
import com.passql.question.entity.Question;
import com.passql.question.event.QuestionSavedEvent;
import com.passql.question.service.QuestionAuditSummary;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * 형식 자동 정리 (#905): 미리보기(바뀌는 필드 전후) > 고른 문제만 적용 (서버가 계획을 다시 계산)
 * 정리 4종: 스키마와 같은 지문 표 삭제(행 0개 표 포함), 개념형 지문 표 > 스키마 표, 목록 기호·줄표·가운뎃점 (보기 글·세트 해설 포함),
 * 지문 SQL·SQL 보기 본문 SELECT 목록 줄바꿈 (#923, 보기는 같은 세트 그대로 갱신)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class QuestionFormatAutoFixService {

    private final QuestionFormatScanScopeLoader scopeLoader;
    private final ApplicationEventPublisher eventPublisher;

    /** 활성 문제 전체 정리 미리보기 (바뀌는 문제만) */
    public List<QuestionFormatFixPreview> preview() {
        QuestionFormatScanScope scope = scopeLoader.loadActiveQuestions();
        return scope.questions().stream()
                .map(question -> QuestionFormatFixPlanner.plan(question, scope))
                .filter(QuestionFormatFixPlanner.Plan::hasChanges)
                .map(plan -> new QuestionFormatFixPreview(plan.question().getQuestionUuid(),
                        TextPreview.truncateWithEllipsis(MarkdownTextStripper.toPlainText(plan.question().getStem()),
                                TextPreview.FORMAT_AUDIT_STEM_LENGTH),
                        scope.mockExamLabelOf(plan.question().getQuestionUuid()), plan.fixNames(), plan.changes()))
                .toList();
    }

    /** 고른 문제 정리 적용: 문제 필드 > 보기 글 > 세트 해설, 문제마다 감사 로그 + 지문 바뀌면 추천 색인 다시 적재 */
    @Transactional
    public QuestionFormatFixApplyResult apply(QuestionFormatFixApplyRequest request) {
        QuestionFormatScanScope scope = scopeLoader.loadQuestions(request.questionUuids());
        int fixedQuestionCount = 0;
        int changedFieldCount = 0;
        for (Question question : scope.questions()) {
            QuestionFormatFixPlanner.Plan plan = QuestionFormatFixPlanner.plan(question, scope);
            if (!plan.hasChanges()) continue;
            applyPlan(plan);
            fixedQuestionCount++;
            changedFieldCount += plan.changes().size();
        }
        int unchangedQuestionCount = request.questionUuids().size() - fixedQuestionCount;
        log.info("[question format] auto fix applied : fixed={}, fields={}, unchanged={}",
                fixedQuestionCount, changedFieldCount, unchangedQuestionCount);
        return new QuestionFormatFixApplyResult(fixedQuestionCount, changedFieldCount, unchangedQuestionCount);
    }

    private void applyPlan(QuestionFormatFixPlanner.Plan plan) {
        Question question = plan.question();
        Map<String, Object> before = QuestionAuditSummary.of(question);
        boolean isStemChanged = !Objects.equals(question.getStem(), plan.questionResult().stem());

        // 문제 필드 (지문·힌트·DDL·샘플)
        question.setStem(plan.questionResult().stem());
        question.setHint(plan.questionResult().hint());
        question.setSchemaDdl(plan.questionResult().schemaDdl());
        question.setSchemaSampleData(plan.questionResult().schemaSampleData());
        // 보기 글·세트 해설
        plan.itemFixes().forEach(itemFix -> {
            itemFix.item().setBody(itemFix.body());
            itemFix.item().setRationale(itemFix.rationale());
            itemFix.item().setExplanation(itemFix.explanation());
        });
        plan.explanationFixes().forEach(explanationFix ->
                explanationFix.choiceSet().setExplanationJson(explanationFix.explanationJson()));

        Map<String, Object> after = QuestionAuditSummary.of(question);
        after.put("formatFixes", String.join(", ", plan.fixNames()));
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.QUESTION, question.getQuestionUuid(),
                AdminAuditAction.UPDATE, before, after));
        if (isStemChanged) eventPublisher.publishEvent(new QuestionSavedEvent(question.getQuestionUuid()));
    }
}
