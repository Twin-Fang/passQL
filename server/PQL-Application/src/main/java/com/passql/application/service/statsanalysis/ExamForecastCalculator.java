package com.passql.application.service.statsanalysis;

import com.passql.ai.constant.AiForecastVerdict;
import com.passql.ai.dto.AiExamForecast;

import java.util.List;
import java.util.Optional;

/**
 * SQLD 예상 점수 (#862): 과목별 예상 정답률 > 1과목 10·2과목 40문항 예상 맞힐 수 > 100점 환산 > 판정·문구 (근거 부족이면 "N문제 더" 안내)
 * 2과목 = 토픽 같은 비중 평균 (문제 은행 토픽별 문제 수는 출제 비중이 아닌 제작량), 풀이 적은 토픽은 2과목 전체 정답률 쪽으로 당김
 */
public final class ExamForecastCalculator {

    // SQLD 문항 수 (1과목 데이터 모델링의 이해 10, 2과목 SQL 기본 및 활용 40), 문항당 2점
    static final int SUBJECT_ONE_QUESTION_COUNT = 10;
    static final int SUBJECT_TWO_QUESTION_COUNT = 40;
    static final int POINTS_PER_QUESTION = 2;
    // 합격 기준: 총점 60 이상, 과목별 40% 이상 (미만이면 과락)
    static final int PASS_SCORE = 60;
    static final double SUBJECT_FAIL_RATE = 0.40;
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

    /** 예상 점수 (근거 부족이면 empty) */
    public static Optional<AiExamForecast> forecast(List<TopicLearningStat> topicStats) {
        List<TopicLearningStat> subjectOneTopics = topicStats.stream().filter(TopicLearningStat::isSubjectOne).toList();
        List<TopicLearningStat> subjectTwoTopics = topicStats.stream().filter(stat -> !stat.isSubjectOne()).toList();
        if (remainingSubjectOneCount(subjectOneTopics) > 0 || remainingSubjectTwoCount(subjectTwoTopics) > 0) {
            return Optional.empty();
        }
        int subjectOneExpected = toExpectedCount(pooledRate(subjectOneTopics), SUBJECT_ONE_QUESTION_COUNT);
        int subjectTwoExpected = toExpectedCount(subjectTwoRate(subjectTwoTopics), SUBJECT_TWO_QUESTION_COUNT);
        return Optional.of(toForecast(subjectOneExpected, subjectTwoExpected));
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

    /** 예상 맞힐 수 > 점수·판정·문구 */
    static AiExamForecast toForecast(int subjectOneExpected, int subjectTwoExpected) {
        int expectedScore = (subjectOneExpected + subjectTwoExpected) * POINTS_PER_QUESTION;
        boolean isSubjectOneFailRisk = subjectOneExpected < failLineCount(SUBJECT_ONE_QUESTION_COUNT);
        boolean isSubjectTwoFailRisk = subjectTwoExpected < failLineCount(SUBJECT_TWO_QUESTION_COUNT);
        AiForecastVerdict verdict = toVerdict(expectedScore, isSubjectOneFailRisk || isSubjectTwoFailRisk);
        String summary = "1과목 예상 " + subjectOneExpected + "/" + SUBJECT_ONE_QUESTION_COUNT
                + " · 2과목 예상 " + subjectTwoExpected + "/" + SUBJECT_TWO_QUESTION_COUNT;
        String detail = verdict == AiForecastVerdict.SUBJECT_FAIL_RISK
                ? toSubjectFailDetail(isSubjectOneFailRisk, isSubjectTwoFailRisk)
                : toScoreGapDetail(expectedScore);
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

    /** 과락 경계 문제 수 (10문항 > 4, 40문항 > 16) */
    private static int failLineCount(int questionCount) {
        return (int) Math.ceil(questionCount * SUBJECT_FAIL_RATE);
    }

    /** "1과목 과락 위험, 10문제 중 4문제 이상 맞혀야 해요" (두 과목 모두면 과목별 40%) */
    private static String toSubjectFailDetail(boolean isSubjectOneFailRisk, boolean isSubjectTwoFailRisk) {
        if (isSubjectOneFailRisk && isSubjectTwoFailRisk) {
            return "두 과목 모두 과락 위험, 과목마다 40% 이상 맞혀야 해요";
        }
        int questionCount = isSubjectOneFailRisk ? SUBJECT_ONE_QUESTION_COUNT : SUBJECT_TWO_QUESTION_COUNT;
        String subjectName = isSubjectOneFailRisk ? "1과목" : "2과목";
        return subjectName + " 과락 위험, " + questionCount + "문제 중 " + failLineCount(questionCount) + "문제 이상 맞혀야 해요";
    }

    /** 합격선 대비 문제 수: 위면 여유, 아래면 더 맞힐 수 */
    private static String toScoreGapDetail(int expectedScore) {
        if (expectedScore == PASS_SCORE) {
            return "합격선에 딱 걸려 있어요, 한 문제가 갈라요";
        }
        if (expectedScore > PASS_SCORE) {
            return "합격선보다 " + (expectedScore - PASS_SCORE) / POINTS_PER_QUESTION + "문제 여유가 있어요";
        }
        int neededCount = (PASS_SCORE - expectedScore + POINTS_PER_QUESTION - 1) / POINTS_PER_QUESTION;
        return "합격선까지 " + neededCount + "문제 더 맞히면 돼요";
    }
}
