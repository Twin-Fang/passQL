package com.passql.submission.service;

import com.passql.question.dto.QuestionFormatCheckResult;
import com.passql.question.dto.QuestionFormatInput;
import com.passql.question.dto.QuestionFormatViolation;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.service.QuestionFormatRule;
import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.dto.mockexam.AdminMockExamPublishCheck;
import com.passql.submission.entity.MockExamRoundItem;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 공개 검사: 오류 4종(문항 수·과목 배분, 번호 1~50, 문제 중복, 문제 활성·세트 출제 가능) / 경고 2종(보기 근거 없음, 형식 위반 #905)
 */
@Component
@RequiredArgsConstructor
public class MockExamPublishChecker {

    private final MockExamEligibleSetFinder eligibleSetFinder;

    public AdminMockExamPublishCheck check(MockExamPaper paper) {
        List<MockExamRoundItem> items = paper.items();
        List<String> errors = new ArrayList<>();
        List<String> warnings = new ArrayList<>();

        // 문항 수·과목 배분 (50 = 10 + 40)
        if (items.size() != MockExamRule.TOTAL_QUESTION_COUNT) {
            errors.add("문항 수 " + items.size() + " (필요 " + MockExamRule.TOTAL_QUESTION_COUNT + ")");
        }
        Arrays.stream(MockExamSubject.values()).forEach(subject -> {
            long subjectCount = items.stream().filter(item -> item.getSubject() == subject).count();
            if (subjectCount != subject.getQuestionCount()) {
                errors.add(subject.getDisplayName() + " " + subjectCount + "문항 (필요 " + subject.getQuestionCount() + ")");
            }
        });

        // 번호 1~N 빠짐없음, 문제 중복 없음
        Set<Integer> questionNumbers = items.stream().map(MockExamRoundItem::getQuestionNumber).collect(Collectors.toSet());
        for (int questionNumber = 1; questionNumber <= MockExamRule.TOTAL_QUESTION_COUNT; questionNumber++) {
            if (!questionNumbers.contains(questionNumber)) {
                errors.add(questionNumber + "번 문항 없음");
            }
        }
        Set<UUID> seenQuestionUuids = new HashSet<>();
        items.stream()
            .filter(item -> !seenQuestionUuids.add(item.getQuestionUuid()))
            .forEach(item -> errors.add(item.getQuestionNumber() + "번 문제 중복"));

        // 문제 활성 + 고정 세트 지금도 출제 가능 (신고·비활성·검증 실패 세트 걸러냄)
        Set<UUID> eligibleSetUuids = eligibleSetFinder.findEligibleSetUuidsAmong(
            items.stream().map(MockExamRoundItem::getChoiceSetUuid).toList());
        for (MockExamRoundItem item : items) {
            Question question = paper.questionOf(item);
            if (question == null || !Boolean.TRUE.equals(question.getIsActive())) {
                errors.add(item.getQuestionNumber() + "번 문제 비활성·삭제됨");
            } else if (!eligibleSetUuids.contains(item.getChoiceSetUuid())) {
                errors.add(item.getQuestionNumber() + "번 보기 세트가 출제 기준 미달 (OK·보기 4개·정답 1개·실행형은 검증 통과)");
            }
            boolean hasMissingRationale = paper.choiceItemsOf(item).stream()
                .map(QuestionChoiceSetItem::getRationale)
                .anyMatch(rationale -> rationale == null || rationale.isBlank());
            if (hasMissingRationale) {
                warnings.add(item.getQuestionNumber() + "번 보기 근거(해설) 없는 보기 있음");
            }
            // 문항 형식 규칙 (#905): 경고만 (기존 문항은 관리자 형식 검사 화면에서 일괄 정리)
            if (question != null) {
                QuestionFormatCheckResult formatResult = QuestionFormatRule.check(
                    QuestionFormatInput.from(question, paper.choiceItemsOf(item)));
                if (!formatResult.isPassed()) {
                    warnings.add(item.getQuestionNumber() + "번 형식 위반 " + formatResult.violations().size() + "건: "
                        + formatResult.violations().stream().map(QuestionFormatViolation::getReasonDisplayName)
                            .distinct().collect(Collectors.joining(", ")));
                }
            }
        }
        return new AdminMockExamPublishCheck(errors.isEmpty(), errors, warnings);
    }

    /** 문항 고정 세트 중 지금도 출제 가능한 세트 (상세 표 표시용) */
    public Set<UUID> findEligibleSetUuids(List<MockExamRoundItem> items) {
        return eligibleSetFinder.findEligibleSetUuidsAmong(items.stream().map(MockExamRoundItem::getChoiceSetUuid).toList());
    }
}
