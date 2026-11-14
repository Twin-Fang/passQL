package com.passql.submission.service;

import com.passql.submission.constant.ExamAnswerPassStatus;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 가채점 핵심 판정 (#1075): 2점·60점 합격·과목 40% 미만 과락, 확정 안 된 문항 점수 범위 > PASS·FAIL·BORDERLINE
 */
class ExamAnswerGraderTest {

    // 모든 문항 정답 1번, 확정
    private static final List<ExamAnswerKey> ALL_DETERMINED_KEYS = keys(Set.of());

    @Test
    void 총점_60점이고_과락_없으면_합격() {
        // 1과목 4개(8점) + 2과목 26개(52점) = 60점
        ExamAnswerGrader.ExamAnswerGrade grade = ExamAnswerGrader.grade(answers(4, 26), ALL_DETERMINED_KEYS);

        assertThat(grade.totalScore()).isEqualTo(60);
        assertThat(grade.passStatus()).isEqualTo(ExamAnswerPassStatus.PASS);
    }

    @Test
    void 일과목_8점_미만이면_총점이_넘어도_과락_불합격() {
        ExamAnswerGrader.ExamAnswerGrade grade = ExamAnswerGrader.grade(answers(3, 40), ALL_DETERMINED_KEYS);

        assertThat(grade.totalScore()).isEqualTo(86);
        assertThat(grade.passStatus()).isEqualTo(ExamAnswerPassStatus.FAIL);
    }

    @Test
    void 확정_안_된_문항이_합격선에_걸치면_BORDERLINE_이고_범위를_준다() {
        // 2과목 11~14번 미확정, 내 답은 그 4문항도 1번 > 표시용 정답 기준 60점, 범위 52~60
        List<ExamAnswerKey> keys = keys(Set.of(11, 12, 13, 14));
        ExamAnswerGrader.ExamAnswerGrade grade = ExamAnswerGrader.grade(answers(4, 26), keys);

        assertThat(grade.totalScore()).isEqualTo(60);
        assertThat(grade.minTotalScore()).isEqualTo(52);
        assertThat(grade.maxTotalScore()).isEqualTo(60);
        assertThat(grade.passStatus()).isEqualTo(ExamAnswerPassStatus.BORDERLINE);
    }

    @Test
    void 모름은_미확정_문항이어도_최고_점수에_더하지_않는다() {
        List<ExamAnswerKey> keys = keys(Set.of(50));
        String answers = answers(4, 25).substring(0, 49) + "0";

        ExamAnswerGrader.ExamAnswerGrade grade = ExamAnswerGrader.grade(answers, keys);

        assertThat(grade.maxTotalScore()).isEqualTo(grade.minTotalScore());
        assertThat(grade.perQuestion().get(49).isCorrect()).isFalse();
    }

    /** 1과목 앞 n개·2과목 앞 m개만 1번(정답), 나머지 2번(오답) */
    private static String answers(int subjectOneCorrectCount, int subjectTwoCorrectCount) {
        StringBuilder answers = new StringBuilder();
        for (int questionNo = 1; questionNo <= 50; questionNo++) {
            boolean isCorrect = questionNo <= 10 ? questionNo <= subjectOneCorrectCount : questionNo - 10 <= subjectTwoCorrectCount;
            answers.append(isCorrect ? '1' : '2');
        }
        return answers.toString();
    }

    /** 정답 전부 1번, 지정 번호만 미확정 */
    private static List<ExamAnswerKey> keys(Set<Integer> undeterminedQuestionNos) {
        List<ExamAnswerKey> keys = new ArrayList<>();
        for (int questionNo = 1; questionNo <= 50; questionNo++) {
            keys.add(new ExamAnswerKey(questionNo, ExamAnswerGrader.toSubjectNo(questionNo), 1, Set.of(1),
                    !undeterminedQuestionNos.contains(questionNo)));
        }
        return keys;
    }
}
