package com.passql.submission.service;

import com.passql.submission.constant.MockExamSubject;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/**
 * 기출 복원 회차 구성 검증 (순수, #1079): 회차 번호 중복, 문항 50개, 문제 중복, 출제 가능 문제, 번호별 과목
 * 문항 순서 = 시험 번호 (1~10 1과목, 11~50 2과목)
 */
public final class MockExamPastRoundRule {

    private MockExamPastRoundRule() {
    }

    /**
     * 구성 오류 목록 (빈 목록이면 통과)
     * @param subjectByEligibleQuestionUuid 출제 가능 세트가 있는 활성 문제 > 과목 (없는 문제는 출제 불가)
     */
    public static List<String> findCompositionErrors(int examRoundNumber, boolean isExamRoundNumberTaken,
                                                     List<UUID> questionUuids,
                                                     Map<UUID, MockExamSubject> subjectByEligibleQuestionUuid) {
        List<String> errors = new ArrayList<>();
        if (isExamRoundNumberTaken) {
            errors.add(examRoundNumber + "회 기출 회차가 이미 있음");
        }
        if (questionUuids.size() != MockExamRule.TOTAL_QUESTION_COUNT) {
            errors.add("문항 수 " + questionUuids.size() + " (필요 " + MockExamRule.TOTAL_QUESTION_COUNT + ")");
        }

        // 번호별 검사 (중복, 출제 가능, 과목)
        Set<UUID> seenQuestionUuids = new HashSet<>();
        for (int index = 0; index < questionUuids.size(); index++) {
            int questionNumber = index + 1;
            UUID questionUuid = questionUuids.get(index);
            if (questionUuid == null) {
                errors.add(questionNumber + "번 문제 uuid 없음");
                continue;
            }
            if (!seenQuestionUuids.add(questionUuid)) {
                errors.add(questionNumber + "번 문제 중복");
                continue;
            }
            MockExamSubject subject = subjectByEligibleQuestionUuid.get(questionUuid);
            if (subject == null) {
                errors.add(questionNumber + "번 문제 출제 불가 (없음·비활성·OK 보기 4개 정답 1개 세트 없음)");
            } else if (subject != subjectOfQuestionNumber(questionNumber)) {
                errors.add(questionNumber + "번 과목 불일치 (필요 " + subjectOfQuestionNumber(questionNumber).getDisplayName()
                    + ", 문제 토픽은 " + subject.getDisplayName() + ")");
            }
        }
        return errors;
    }

    /** 시험 번호 > 과목 (1~10 1과목, 그 뒤 2과목) */
    public static MockExamSubject subjectOfQuestionNumber(int questionNumber) {
        return questionNumber <= MockExamSubject.SUBJECT_ONE.getQuestionCount()
            ? MockExamSubject.SUBJECT_ONE : MockExamSubject.SUBJECT_TWO;
    }
}
