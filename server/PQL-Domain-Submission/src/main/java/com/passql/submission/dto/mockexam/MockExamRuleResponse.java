package com.passql.submission.dto.mockexam;

import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.service.MockExamRule;

import java.util.Arrays;
import java.util.List;

/**
 * 시험 형식 (앱·웹 안내 문구 원본): 문항 수·시간·만점·합격선·과목별 과락선
 */
public record MockExamRuleResponse(
    int questionCount,
    int durationMinutes,
    int maxScore,
    int passScore,
    int pointsPerQuestion,
    List<SubjectRule> subjects
) {

    public record SubjectRule(MockExamSubject subject, String name, int questionCount, int maxScore, int failBelowScore) {
    }

    /** MockExamRule 상수 > 응답 */
    public static MockExamRuleResponse fromRule() {
        List<SubjectRule> subjectRules = Arrays.stream(MockExamSubject.values())
            .map(subject -> new SubjectRule(subject, subject.getDisplayName(), subject.getQuestionCount(),
                MockExamRule.maxScoreOf(subject), MockExamRule.failBelowScoreOf(subject)))
            .toList();
        return new MockExamRuleResponse(MockExamRule.TOTAL_QUESTION_COUNT, MockExamRule.DURATION_MINUTES,
            MockExamRule.MAX_SCORE, MockExamRule.PASS_SCORE, MockExamRule.POINTS_PER_QUESTION, subjectRules);
    }
}
