package com.passql.submission.service;

import com.passql.submission.constant.MockExamFailReason;
import com.passql.submission.constant.MockExamSubject;

import java.util.EnumMap;
import java.util.List;
import java.util.Map;

/**
 * 모의고사 채점 (순수 판정): 문항별 정오 > 과목별 점수 > 과락 > 합격
 * 안 푼 문항은 오답, 과락이 있으면 총점과 무관하게 불합격
 */
public final class MockExamGrader {

    private MockExamGrader() {
    }

    /** 채점할 문항 1개 (안 푼 문항은 isCorrect=false) */
    public record GradedQuestion(MockExamSubject subject, boolean isCorrect) {
    }

    /** 과목 점수 */
    public record SubjectScore(MockExamSubject subject, int correctCount, int questionCount, int score,
                               int maxScore, boolean isFailed) {
    }

    /** 채점 결과 */
    public record MockExamScore(int correctCount, int totalScore, List<SubjectScore> subjectScores,
                                boolean isPassed, MockExamFailReason failReason) {

        public SubjectScore subjectScoreOf(MockExamSubject subject) {
            return subjectScores.stream()
                .filter(subjectScore -> subjectScore.subject() == subject)
                .findFirst()
                .orElseThrow();
        }
    }

    /** 문항 정오 목록 > 채점 결과 */
    public static MockExamScore grade(List<GradedQuestion> gradedQuestions) {
        // 과목별 정답·문항 수
        Map<MockExamSubject, int[]> correctAndTotalBySubject = new EnumMap<>(MockExamSubject.class);
        for (MockExamSubject subject : MockExamSubject.values()) {
            correctAndTotalBySubject.put(subject, new int[2]);
        }
        for (GradedQuestion gradedQuestion : gradedQuestions) {
            int[] correctAndTotal = correctAndTotalBySubject.get(gradedQuestion.subject());
            if (gradedQuestion.isCorrect()) {
                correctAndTotal[0]++;
            }
            correctAndTotal[1]++;
        }

        // 과목 점수·과락 (만점은 공식 문항 수 기준: 문항이 빠진 회차도 과락선이 내려가지 않게)
        List<SubjectScore> subjectScores = correctAndTotalBySubject.entrySet().stream()
            .map(entry -> toSubjectScore(entry.getKey(), entry.getValue()[0], entry.getValue()[1]))
            .toList();
        int correctCount = subjectScores.stream().mapToInt(SubjectScore::correctCount).sum();
        int totalScore = correctCount * MockExamRule.POINTS_PER_QUESTION;

        // 합격: 과락 우선 > 총점
        boolean hasSubjectFail = subjectScores.stream().anyMatch(SubjectScore::isFailed);
        MockExamFailReason failReason = hasSubjectFail ? MockExamFailReason.SUBJECT_FAIL
            : totalScore < MockExamRule.PASS_SCORE ? MockExamFailReason.TOTAL_SCORE_BELOW
            : MockExamFailReason.NONE;
        return new MockExamScore(correctCount, totalScore, subjectScores,
            failReason == MockExamFailReason.NONE, failReason);
    }

    private static SubjectScore toSubjectScore(MockExamSubject subject, int correctCount, int questionCount) {
        int score = correctCount * MockExamRule.POINTS_PER_QUESTION;
        boolean isFailed = score < MockExamRule.failBelowScoreOf(subject);
        return new SubjectScore(subject, correctCount, questionCount, score, MockExamRule.maxScoreOf(subject), isFailed);
    }
}
