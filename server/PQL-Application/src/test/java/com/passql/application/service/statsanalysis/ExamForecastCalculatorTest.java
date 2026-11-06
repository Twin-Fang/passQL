package com.passql.application.service.statsanalysis;

import com.passql.ai.constant.AiForecastVerdict;
import com.passql.ai.dto.AiExamForecast;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * SQLD 예상 점수 (#862): 과목별 예상 맞힐 수, 과락·합격선 판정, 근거 부족 안내
 */
class ExamForecastCalculatorTest {

    private static TopicLearningStat topic(String displayName, boolean isSubjectOne, int solvedCount, double correctRate) {
        return new TopicLearningStat(UUID.nameUUIDFromBytes(displayName.getBytes()), displayName, isSubjectOne,
                solvedCount, correctRate);
    }

    @Test
    void 과목별_예상_맞힐_수와_합격선_근처_판정() {
        AiExamForecast forecast = ExamForecastCalculator.forecast(List.of(
                topic("데이터 모델링의 이해", true, 10, 0.6),
                topic("조인 (JOIN)", false, 20, 0.65),
                topic("서브쿼리", false, 20, 0.65))).orElseThrow();

        assertThat(forecast.summary()).isEqualTo("1과목 예상 6/10 · 2과목 예상 26/40");
        assertThat(forecast.expectedScore()).isEqualTo(64);
        assertThat(forecast.verdict()).isEqualTo(AiForecastVerdict.BORDERLINE);
        assertThat(forecast.detail()).isEqualTo("합격선보다 2문제 여유가 있어요");
    }

    @Test
    void 과목_하나라도_40퍼센트_미만이면_총점과_무관하게_과락_위험() {
        AiExamForecast forecast = ExamForecastCalculator.toForecast(3, 36);

        assertThat(forecast.expectedScore()).isEqualTo(78);
        assertThat(forecast.verdict()).isEqualTo(AiForecastVerdict.SUBJECT_FAIL_RISK);
        assertThat(forecast.isSubjectOneFailRisk()).isTrue();
        assertThat(forecast.detail()).isEqualTo("1과목 과락 위험, 10문제 중 4문제 이상 맞혀야 해요");
    }

    @Test
    void 판정_구간_경계() {
        assertThat(ExamForecastCalculator.toVerdict(70, false)).isEqualTo(AiForecastVerdict.PASS_LIKELY);
        assertThat(ExamForecastCalculator.toVerdict(54, false)).isEqualTo(AiForecastVerdict.BORDERLINE);
        assertThat(ExamForecastCalculator.toVerdict(52, false)).isEqualTo(AiForecastVerdict.BELOW_PASS);
        assertThat(ExamForecastCalculator.toForecast(5, 22).detail()).isEqualTo("합격선까지 3문제 더 맞히면 돼요");
    }

    @Test
    void 이과목_풀이가_적은_토픽은_이과목_전체_정답률_쪽으로_당긴다() {
        // 전체 정답률 (20*0.5 + 2*1.0) / 22 = 0.545, 2문제 100% 토픽은 (2 + 5*0.545)/7 = 0.675 로 당겨짐
        double rate = ExamForecastCalculator.subjectTwoRate(List.of(
                topic("조인 (JOIN)", false, 20, 0.5),
                topic("서브쿼리", false, 2, 1.0)));

        assertThat(rate).isBetween(0.58, 0.60);
    }

    @Test
    void 근거_부족이면_예상_대신_남은_문제_수_안내() {
        List<TopicLearningStat> topics = List.of(
                topic("데이터 모델링의 이해", true, 3, 0.6),
                topic("조인 (JOIN)", false, 12, 0.65));

        assertThat(ExamForecastCalculator.forecast(topics)).isEmpty();
        assertThat(ExamForecastCalculator.toMissingDataHint(topics)).isEqualTo("1과목 2문제·2과목 8문제 더 풀면 예상 점수를 알려 드려요");
    }
}
