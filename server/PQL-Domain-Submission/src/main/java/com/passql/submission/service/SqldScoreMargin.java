package com.passql.submission.service;

import com.passql.submission.constant.MockExamSubject;

/**
 * SQLD 과락선·합격선 여유 문항 수 (#1111): 정답 수 > 기준까지 남은·남는 문제 수 > 안내 문구
 * 기준은 MockExamRule 원본 (문항 2점, 과목 40% 미만 과락, 60점 합격). 여유 = 더 틀려도 되는 문제 수, 음수면 더 맞혀야 할 문제 수
 */
public final class SqldScoreMargin {

    private SqldScoreMargin() {
    }

    /** 과락을 면하는 최소 정답 수: 1과목 4, 2과목 16 */
    public static int minCorrectCountToAvoidFailOf(MockExamSubject subject) {
        return ceilDivide(MockExamRule.failBelowScoreOf(subject), MockExamRule.POINTS_PER_QUESTION);
    }

    /** 합격 최소 정답 수: 30 */
    public static int minCorrectCountToPass() {
        return ceilDivide(MockExamRule.PASS_SCORE, MockExamRule.POINTS_PER_QUESTION);
    }

    /** 과목 과락 여유: 0 이상이면 더 틀려도 되는 수, 음수면 과락을 넘으려 더 맞혀야 할 수 */
    public static int failMarginCountOf(MockExamSubject subject, int correctCount) {
        return correctCount - minCorrectCountToAvoidFailOf(subject);
    }

    /** 합격선 여유: 0 이상이면 더 틀려도 되는 수, 음수면 더 맞혀야 할 수 */
    public static int passMarginCountOf(int totalCorrectCount) {
        return totalCorrectCount - minCorrectCountToPass();
    }

    /** 과목 칸 문구: "과락까지 여유 2문제" / "한 문제만 더 틀리면 과락" / "과락을 넘으려면 1문제 더" */
    public static String toFailMarginText(int failMarginCount) {
        if (failMarginCount > 0) {
            return "과락까지 여유 " + failMarginCount + "문제";
        }
        if (failMarginCount == 0) {
            return "한 문제만 더 틀리면 과락";
        }
        return "과락을 넘으려면 " + (-failMarginCount) + "문제 더";
    }

    /** 합격선 문장: "합격선까지 3문제 더 맞히면 돼요" / "합격선보다 2문제 여유가 있어요" / 딱 걸림 */
    public static String toPassMarginText(int passMarginCount) {
        if (passMarginCount > 0) {
            return "합격선보다 " + passMarginCount + "문제 여유가 있어요";
        }
        if (passMarginCount == 0) {
            return "합격선에 딱 걸려 있어요, 한 문제가 갈라요";
        }
        return "합격선까지 " + (-passMarginCount) + "문제 더 맞히면 돼요";
    }

    /** 합격선 짧은 구 (과목 여유와 한 줄로 이을 때): "합격선까지 3문제 더" / "합격선보다 2문제 여유" / "합격선에 딱 맞음" */
    public static String toPassMarginShortText(int passMarginCount) {
        if (passMarginCount > 0) {
            return "합격선보다 " + passMarginCount + "문제 여유";
        }
        if (passMarginCount == 0) {
            return "합격선에 딱 맞음";
        }
        return "합격선까지 " + (-passMarginCount) + "문제 더";
    }

    private static int ceilDivide(int dividend, int divisor) {
        return (dividend + divisor - 1) / divisor;
    }
}
