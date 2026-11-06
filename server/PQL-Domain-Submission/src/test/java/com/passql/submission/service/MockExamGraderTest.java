package com.passql.submission.service;

import com.passql.submission.constant.MockExamFailReason;
import com.passql.submission.constant.MockExamSubject;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 모의고사 채점 판정 (#866): 문항당 2점, 60점 합격, 과목별 40% 미만 과락(1과목 8점·2과목 32점 미만)
 */
class MockExamGraderTest {

    @Test
    void 총점_60점이고_과락_없으면_합격() {
        MockExamGrader.MockExamScore score = MockExamGrader.grade(exam(4, 26));

        assertThat(score.totalScore()).isEqualTo(60);
        assertThat(score.isPassed()).isTrue();
        assertThat(score.failReason()).isEqualTo(MockExamFailReason.NONE);
    }

    @Test
    void 일과목_정답_3개면_총점이_넘어도_과락_불합격() {
        MockExamGrader.MockExamScore score = MockExamGrader.grade(exam(3, 40));

        assertThat(score.totalScore()).isEqualTo(86);
        assertThat(score.subjectScoreOf(MockExamSubject.SUBJECT_ONE).isFailed()).isTrue();
        assertThat(score.isPassed()).isFalse();
        assertThat(score.failReason()).isEqualTo(MockExamFailReason.SUBJECT_FAIL);
    }

    @Test
    void 일과목_정답_4개_8점은_과락_아님() {
        MockExamGrader.MockExamScore score = MockExamGrader.grade(exam(4, 16));

        assertThat(score.subjectScoreOf(MockExamSubject.SUBJECT_ONE).isFailed()).isFalse();
        assertThat(score.subjectScoreOf(MockExamSubject.SUBJECT_TWO).isFailed()).isFalse();
        assertThat(score.failReason()).isEqualTo(MockExamFailReason.TOTAL_SCORE_BELOW);
    }

    @Test
    void 이과목_정답_15개_30점은_과락() {
        MockExamGrader.MockExamScore score = MockExamGrader.grade(exam(10, 15));

        assertThat(score.subjectScoreOf(MockExamSubject.SUBJECT_TWO).isFailed()).isTrue();
        assertThat(score.failReason()).isEqualTo(MockExamFailReason.SUBJECT_FAIL);
    }

    @Test
    void 안_푼_문항은_오답으로_채점() {
        MockExamGrader.MockExamScore score = MockExamGrader.grade(exam(0, 0));

        assertThat(score.correctCount()).isZero();
        assertThat(score.isPassed()).isFalse();
    }

    /** 1과목 10문항 중 subjectOneCorrect 개, 2과목 40문항 중 subjectTwoCorrect 개 정답 */
    private static List<MockExamGrader.GradedQuestion> exam(int subjectOneCorrect, int subjectTwoCorrect) {
        List<MockExamGrader.GradedQuestion> gradedQuestions = new ArrayList<>();
        for (int index = 0; index < MockExamSubject.SUBJECT_ONE.getQuestionCount(); index++) {
            gradedQuestions.add(new MockExamGrader.GradedQuestion(MockExamSubject.SUBJECT_ONE, index < subjectOneCorrect));
        }
        for (int index = 0; index < MockExamSubject.SUBJECT_TWO.getQuestionCount(); index++) {
            gradedQuestions.add(new MockExamGrader.GradedQuestion(MockExamSubject.SUBJECT_TWO, index < subjectTwoCorrect));
        }
        return gradedQuestions;
    }
}
