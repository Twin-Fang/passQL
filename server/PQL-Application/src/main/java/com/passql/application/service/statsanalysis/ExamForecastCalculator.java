package com.passql.application.service.statsanalysis;

import com.passql.ai.constant.AiForecastVerdict;
import com.passql.ai.dto.AiExamForecast;

import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.service.MockExamRule;
import com.passql.submission.service.SqldScoreMargin;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.OptionalInt;

/**
 * SQLD 예상 점수 (#862): 과목별 예상 정답률 > 1과목 10·2과목 40문항 예상 맞힐 수 > 100점 환산 > 판정·여유 문구(#1111) (근거 부족이면 "N문제 더" 안내)
 * 2과목 = 토픽 같은 비중 평균 (문제 은행 토픽별 문제 수는 출제 비중이 아닌 제작량), 풀이 적은 토픽은 2과목 전체 정답률 쪽으로 당김
 */
public final class ExamForecastCalculator {

    // SQLD 문항 수·배점 (원본 MockExamSubject·MockExamRule: 1과목 10, 2과목 40, 문항당 2점, 60점 합격, 과목 40% 미만 과락)
    static final int SUBJECT_ONE_QUESTION_COUNT = MockExamSubject.SUBJECT_ONE.getQuestionCount();
    static final int SUBJECT_TWO_QUESTION_COUNT = MockExamSubject.SUBJECT_TWO.getQuestionCount();
    static final int POINTS_PER_QUESTION = MockExamRule.POINTS_PER_QUESTION;
    // 판정 구간: 70점 이상 합격권(합격선 + 5문제), 54점 이상 합격선 근처(합격선 - 3문제)
    static final int PASS_LIKELY_SCORE = 70;
    static final int BORDERLINE_MIN_SCORE = 54;
    // 예상에 필요한 최소 풀이 수 (최근 90일, 문제별 마지막 시도)
    static final int SUBJECT_ONE_MIN_SOLVED = 5;
    static final int SUBJECT_TWO_MIN_SOLVED = 20;
    // 토픽 정답률을 2과목 전체 정답률 쪽으로 당기는 가중 (가상 풀이 수)
    static final double SHRINK_PRIOR_SOLVED_COUNT = 5.0;

    private ExamForecastCalculator() {
    }

    /** 예상 점수 (두 과목 중 하나라도 근거 부족이면 empty) */
    public static Optional<AiExamForecast> forecast(List<TopicLearningStat> topicStats) {
        OptionalInt subjectOneExpected = expectedCorrectCountOf(MockExamSubject.SUBJECT_ONE, topicStats);
        OptionalInt subjectTwoExpected = expectedCorrectCountOf(MockExamSubject.SUBJECT_TWO, topicStats);
        if (subjectOneExpected.isEmpty() || subjectTwoExpected.isEmpty()) {
            return Optional.empty();
        }
        return Optional.of(toForecast(subjectOneExpected.getAsInt(), subjectTwoExpected.getAsInt()));
    }

    /**
     * 과목 예상 맞힐 수 (그 과목 근거 부족이면 empty)
     * 1과목 = 풀이 수 가중 정답률, 2과목 = 토픽 같은 비중 평균 (subjectTwoRate)
     */
    public static OptionalInt expectedCorrectCountOf(MockExamSubject subject, List<TopicLearningStat> topicStats) {
        boolean isSubjectOne = subject == MockExamSubject.SUBJECT_ONE;
        List<TopicLearningStat> subjectTopics = topicStats.stream()
                .filter(stat -> stat.isSubjectOne() == isSubjectOne)
                .toList();
        int remainingCount = isSubjectOne ? remainingSubjectOneCount(subjectTopics) : remainingSubjectTwoCount(subjectTopics);
        if (remainingCount > 0) {
            return OptionalInt.empty();
        }
        double expectedRate = isSubjectOne ? pooledRate(subjectTopics) : subjectTwoRate(subjectTopics);
        return OptionalInt.of(toExpectedCount(expectedRate, subject.getQuestionCount()));
    }

    /**
     * 과락 위험 과목 (과목별 예상 맞힐 수 < 과락 면하는 수, SqldScoreMargin 기준)
     * 근거 부족 과목은 판정하지 않음. AI 분석 한 줄 요약·예상 점수가 함께 쓰는 과락 판정 원본 (#1136)
     */
    public static List<MockExamSubject> failRiskSubjectsOf(List<TopicLearningStat> topicStats) {
        return Arrays.stream(MockExamSubject.values())
                .filter(subject -> expectedCorrectCountOf(subject, topicStats)
                        .stream()
                        .anyMatch(expectedCount -> SqldScoreMargin.failMarginCountOf(subject, expectedCount) < 0))
                .toList();
    }

    /** 근거 부족 안내: "1과목 2문제·2과목 8문제 더 풀면 예상 점수를 알려 드려요" (예상 가능하면 null) */
    public static String toMissingDataHint(List<TopicLearningStat> topicStats) {
        int subjectOneRemaining = remainingSubjectOneCount(topicStats.stream().filter(TopicLearningStat::isSubjectOne).toList());
        int subjectTwoRemaining = remainingSubjectTwoCount(topicStats.stream().filter(stat -> !stat.isSubjectOne()).toList());
        if (subjectOneRemaining == 0 && subjectTwoRemaining == 0) {
            return null;
        }
        String remainingText = subjectOneRemaining > 0 && subjectTwoRemaining > 0
                ? "1과목 " + subjectOneRemaining + "문제·2과목 " + subjectTwoRemaining + "문제"
                : subjectOneRemaining > 0 ? "1과목 " + subjectOneRemaining + "문제" : "2과목 " + subjectTwoRemaining + "문제";
        return remainingText + " 더 풀면 예상 점수를 알려 드려요";
    }

    /** 예상 맞힐 수 > 점수·판정·문구 (과락·합격선 여유는 SqldScoreMargin 원본) */
    static AiExamForecast toForecast(int subjectOneExpected, int subjectTwoExpected) {
        int expectedScore = (subjectOneExpected + subjectTwoExpected) * POINTS_PER_QUESTION;
        int subjectOneFailMargin = SqldScoreMargin.failMarginCountOf(MockExamSubject.SUBJECT_ONE, subjectOneExpected);
        int subjectTwoFailMargin = SqldScoreMargin.failMarginCountOf(MockExamSubject.SUBJECT_TWO, subjectTwoExpected);
        boolean isSubjectOneFailRisk = subjectOneFailMargin < 0;
        boolean isSubjectTwoFailRisk = subjectTwoFailMargin < 0;
        AiForecastVerdict verdict = toVerdict(expectedScore, isSubjectOneFailRisk || isSubjectTwoFailRisk);
        String summary = "1과목 예상 " + subjectOneExpected + "/" + SUBJECT_ONE_QUESTION_COUNT
                + " · 2과목 예상 " + subjectTwoExpected + "/" + SUBJECT_TWO_QUESTION_COUNT;
        String detail = verdict == AiForecastVerdict.SUBJECT_FAIL_RISK
                ? toSubjectFailDetail(subjectOneFailMargin, subjectTwoFailMargin)
                : toMarginDetail(subjectOneFailMargin, subjectTwoFailMargin,
                        SqldScoreMargin.passMarginCountOf(subjectOneExpected + subjectTwoExpected));
        return new AiExamForecast(expectedScore, subjectOneExpected, SUBJECT_ONE_QUESTION_COUNT, isSubjectOneFailRisk,
                subjectTwoExpected, SUBJECT_TWO_QUESTION_COUNT, isSubjectTwoFailRisk, verdict, toVerdictLabel(verdict),
                summary, detail);
    }

    static AiForecastVerdict toVerdict(int expectedScore, boolean hasSubjectFailRisk) {
        if (hasSubjectFailRisk) {
            return AiForecastVerdict.SUBJECT_FAIL_RISK;
        }
        if (expectedScore >= PASS_LIKELY_SCORE) {
            return AiForecastVerdict.PASS_LIKELY;
        }
        return expectedScore >= BORDERLINE_MIN_SCORE ? AiForecastVerdict.BORDERLINE : AiForecastVerdict.BELOW_PASS;
    }

    static String toVerdictLabel(AiForecastVerdict verdict) {
        return switch (verdict) {
            case SUBJECT_FAIL_RISK -> "과락 위험";
            case PASS_LIKELY -> "합격권";
            case BORDERLINE -> "합격선 근처";
            case BELOW_PASS -> "합격선 아래";
        };
    }

    /** 2과목 정답률: 토픽별(2과목 전체 정답률 쪽으로 당김) 같은 비중 평균, 0문제 토픽은 2과목 전체 정답률 */
    static double subjectTwoRate(List<TopicLearningStat> subjectTwoTopics) {
        double pooledRate = pooledRate(subjectTwoTopics);
        return subjectTwoTopics.stream()
                .mapToDouble(stat -> (stat.solvedCount() * stat.correctRate() + SHRINK_PRIOR_SOLVED_COUNT * pooledRate)
                        / (stat.solvedCount() + SHRINK_PRIOR_SOLVED_COUNT))
                .average()
                .orElse(pooledRate);
    }

    /** 토픽들 전체 정답률 (풀이 수 가중, 풀이 없으면 0) */
    private static double pooledRate(List<TopicLearningStat> topics) {
        int solvedCount = topics.stream().mapToInt(TopicLearningStat::solvedCount).sum();
        double correctCount = topics.stream().mapToDouble(stat -> stat.solvedCount() * stat.correctRate()).sum();
        return solvedCount == 0 ? 0.0 : correctCount / solvedCount;
    }

    private static int remainingSubjectOneCount(List<TopicLearningStat> subjectOneTopics) {
        return Math.max(0, SUBJECT_ONE_MIN_SOLVED - subjectOneTopics.stream().mapToInt(TopicLearningStat::solvedCount).sum());
    }

    private static int remainingSubjectTwoCount(List<TopicLearningStat> subjectTwoTopics) {
        return Math.max(0, SUBJECT_TWO_MIN_SOLVED - subjectTwoTopics.stream().mapToInt(TopicLearningStat::solvedCount).sum());
    }

    private static int toExpectedCount(double rate, int questionCount) {
        return (int) Math.round(rate * questionCount);
    }

    /** 과락 위험 문장: "1과목 과락을 넘으려면 1문제 더 맞혀야 해요" (두 과목이면 과목별 문제 수) */
    private static String toSubjectFailDetail(int subjectOneFailMargin, int subjectTwoFailMargin) {
        if (subjectOneFailMargin < 0 && subjectTwoFailMargin < 0) {
            return "두 과목 모두 과락 위험, 1과목 " + (-subjectOneFailMargin) + "문제, 2과목 "
                    + (-subjectTwoFailMargin) + "문제 더 맞혀야 해요";
        }
        boolean isSubjectOneFailRisk = subjectOneFailMargin < 0;
        int neededCount = -(isSubjectOneFailRisk ? subjectOneFailMargin : subjectTwoFailMargin);
        return (isSubjectOneFailRisk ? "1과목" : "2과목") + " 과락을 넘으려면 " + neededCount + "문제 더 맞혀야 해요";
    }

    /** 여유 한 줄 (#1111): 여유가 적은 과목(같으면 1과목) 과락 여유 · 합격선 거리. 예: "1과목 과락까지 여유 2문제, 합격선까지 3문제 더" */
    static String toMarginDetail(int subjectOneFailMargin, int subjectTwoFailMargin, int passMargin) {
        boolean isSubjectOneTighter = subjectOneFailMargin <= subjectTwoFailMargin;
        String subjectName = isSubjectOneTighter ? "1과목 " : "2과목 ";
        int tighterFailMargin = isSubjectOneTighter ? subjectOneFailMargin : subjectTwoFailMargin;
        return subjectName + SqldScoreMargin.toFailMarginText(tighterFailMargin)
                + ", " + SqldScoreMargin.toPassMarginShortText(passMargin);
    }
}
