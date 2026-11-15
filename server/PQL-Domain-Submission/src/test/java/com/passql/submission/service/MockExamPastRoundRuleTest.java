package com.passql.submission.service;

import com.passql.submission.constant.MockExamSubject;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 기출 복원 회차 구성 검증 (#1079): 50문항, 1~10번 1과목·11~50번 2과목, 문제 중복·출제 불가, 회차 번호 중복
 */
class MockExamPastRoundRuleTest {

    private static final int EXAM_ROUND_NUMBER = 62;

    @Test
    void 과목_순서가_맞는_50문항은_통과() {
        List<UUID> questionUuids = new ArrayList<>();
        Map<UUID, MockExamSubject> subjectByQuestionUuid = validComposition(questionUuids);

        assertThat(MockExamPastRoundRule.findCompositionErrors(EXAM_ROUND_NUMBER, false, questionUuids,
            subjectByQuestionUuid)).isEmpty();
    }

    @Test
    void 문항_수_과목_순서_중복_출제불가를_거부() {
        List<UUID> questionUuids = new ArrayList<>();
        Map<UUID, MockExamSubject> subjectByQuestionUuid = validComposition(questionUuids);
        // 1번 자리에 2과목 문제, 12번에 11번 중복, 13번은 출제 불가 문제
        questionUuids.set(0, UUID.randomUUID());
        subjectByQuestionUuid.put(questionUuids.get(0), MockExamSubject.SUBJECT_TWO);
        questionUuids.set(11, questionUuids.get(10));
        questionUuids.set(12, UUID.randomUUID());

        List<String> errors = MockExamPastRoundRule.findCompositionErrors(EXAM_ROUND_NUMBER, false, questionUuids,
            subjectByQuestionUuid);

        assertThat(errors).hasSize(3);
        assertThat(errors.get(0)).startsWith("1번 과목 불일치");
        assertThat(errors.get(1)).startsWith("12번 문제 중복");
        assertThat(errors.get(2)).startsWith("13번 문제 출제 불가");
        assertThat(MockExamPastRoundRule.findCompositionErrors(EXAM_ROUND_NUMBER, false,
            questionUuids.subList(0, 49), subjectByQuestionUuid)).anyMatch(error -> error.startsWith("문항 수 49"));
    }

    @Test
    void 같은_회차_번호가_있으면_거부() {
        List<UUID> questionUuids = new ArrayList<>();
        Map<UUID, MockExamSubject> subjectByQuestionUuid = validComposition(questionUuids);

        assertThat(MockExamPastRoundRule.findCompositionErrors(EXAM_ROUND_NUMBER, true, questionUuids,
            subjectByQuestionUuid)).containsExactly("62회 기출 회차가 이미 있음");
    }

    /** 1~10번 1과목, 11~50번 2과목 문제 50개 */
    private static Map<UUID, MockExamSubject> validComposition(List<UUID> questionUuids) {
        Map<UUID, MockExamSubject> subjectByQuestionUuid = new HashMap<>();
        for (int questionNumber = 1; questionNumber <= MockExamRule.TOTAL_QUESTION_COUNT; questionNumber++) {
            UUID questionUuid = UUID.randomUUID();
            questionUuids.add(questionUuid);
            subjectByQuestionUuid.put(questionUuid, questionNumber <= 10 ? MockExamSubject.SUBJECT_ONE : MockExamSubject.SUBJECT_TWO);
        }
        return subjectByQuestionUuid;
    }
}
