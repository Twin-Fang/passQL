package com.passql.submission.service;

import com.passql.submission.constant.ExamAnswerPassStatus;
import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.dto.examanswer.ExamAnswerQuestionResultResponse;

import java.util.ArrayList;
import java.util.List;

/**
 * SQLD 가채점 (순수 계산): 문항 2점, 1과목 1~10 / 2과목 11~50, 60점 이상 + 과목 40% 이상 합격
 * 점수 범위: 확정 안 된 문항을 틀림(최저) / 맞음(최고)으로 가정 > 둘 다 합격 PASS, 둘 다 불합격 FAIL, 그 외 BORDERLINE
 * 규칙 숫자 원본: MockExamRule (모의고사와 같은 SQLD 공식 기준)
 */
public final class ExamAnswerGrader {

    private ExamAnswerGrader() {
    }

    /** 과목 점수 3종 (표시용 정답 기준·최저·최고) */
    public record SubjectScore(int score, int minScore, int maxScore) {
    }

    /** 채점 결과 (응답 변환 전) */
    public record ExamAnswerGrade(SubjectScore subject1, SubjectScore subject2, ExamAnswerPassStatus passStatus,
                                  List<ExamAnswerQuestionResultResponse> perQuestion) {

        public int totalScore() {
            return subject1.score() + subject2.score();
        }

        public int minTotalScore() {
            return subject1.minScore() + subject2.minScore();
        }

        public int maxTotalScore() {
            return subject1.maxScore() + subject2.maxScore();
        }
    }

    /** 내 답 50자 + 문항 50개 채점 기준(번호 오름차순) > 채점 결과 */
    public static ExamAnswerGrade grade(String answers, List<ExamAnswerKey> keys) {
        int[] scoreBySubject = new int[3];
        int[] minScoreBySubject = new int[3];
        int[] maxScoreBySubject = new int[3];
        List<ExamAnswerQuestionResultResponse> perQuestion = new ArrayList<>(keys.size());

        // 문항별 정오 > 과목별 점수·최저·최고 누적
        for (ExamAnswerKey key : keys) {
            int myAnswer = toMyAnswer(answers, key.questionNo());
            boolean isAccepted = key.isAccepted(myAnswer);
            int subjectIndex = key.subjectNo();
            if (isAccepted) {
                scoreBySubject[subjectIndex] += MockExamRule.POINTS_PER_QUESTION;
            }
            if (key.isDetermined()) {
                int determinedPoints = isAccepted ? MockExamRule.POINTS_PER_QUESTION : 0;
                minScoreBySubject[subjectIndex] += determinedPoints;
                maxScoreBySubject[subjectIndex] += determinedPoints;
            } else if (myAnswer != 0) {
                // 확정 안 된 문항: 모름(0)이 아니면 최고 점수에서만 맞음
                maxScoreBySubject[subjectIndex] += MockExamRule.POINTS_PER_QUESTION;
            }
            Boolean isCorrect = key.answer() == null ? null : isAccepted;
            perQuestion.add(new ExamAnswerQuestionResultResponse(key.questionNo(), myAnswer, key.answer(), isCorrect));
        }

        SubjectScore subject1 = new SubjectScore(scoreBySubject[1], minScoreBySubject[1], maxScoreBySubject[1]);
        SubjectScore subject2 = new SubjectScore(scoreBySubject[2], minScoreBySubject[2], maxScoreBySubject[2]);
        return new ExamAnswerGrade(subject1, subject2, decidePassStatus(subject1, subject2), List.copyOf(perQuestion));
    }

    /** 표시용 정답 기준 총점만 (참여자 점수 분포용) */
    public static int calculateTotalScore(String answers, List<ExamAnswerKey> keys) {
        int totalScore = 0;
        for (ExamAnswerKey key : keys) {
            if (key.isAccepted(toMyAnswer(answers, key.questionNo()))) {
                totalScore += MockExamRule.POINTS_PER_QUESTION;
            }
        }
        return totalScore;
    }

    /** 최저 점수로 합격 > PASS, 최고 점수로도 불합격 > FAIL, 그 외 BORDERLINE */
    static ExamAnswerPassStatus decidePassStatus(SubjectScore subject1, SubjectScore subject2) {
        if (isPassed(subject1.minScore(), subject2.minScore())) {
            return ExamAnswerPassStatus.PASS;
        }
        if (!isPassed(subject1.maxScore(), subject2.maxScore())) {
            return ExamAnswerPassStatus.FAIL;
        }
        return ExamAnswerPassStatus.BORDERLINE;
    }

    /** 합격 = 총점 60 이상 AND 과락 없음 */
    public static boolean isPassed(int subject1Score, int subject2Score) {
        return subject1Score + subject2Score >= MockExamRule.PASS_SCORE
                && !isSubjectFailCut(MockExamSubject.SUBJECT_ONE, subject1Score)
                && !isSubjectFailCut(MockExamSubject.SUBJECT_TWO, subject2Score);
    }

    /** 과락 = 과목 만점 40% 미만 (1과목 8점·2과목 32점 미만) */
    public static boolean isSubjectFailCut(MockExamSubject subject, int subjectScore) {
        return subjectScore < MockExamRule.failBelowScoreOf(subject);
    }

    /** 문항 번호 > 과목 번호 (1과목 문항 수 이하면 1) */
    public static int toSubjectNo(int questionNo) {
        return questionNo <= MockExamSubject.SUBJECT_ONE.getQuestionCount() ? 1 : 2;
    }

    /** 답안 문자열의 해당 번호 자리 > 0~4 (범위 밖 0) */
    private static int toMyAnswer(String answers, int questionNo) {
        int myAnswer = answers.charAt(questionNo - 1) - '0';
        return myAnswer >= 1 && myAnswer <= ExamAnswerKeyResolver.CHOICE_COUNT ? myAnswer : 0;
    }
}
