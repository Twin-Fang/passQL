package com.passql.submission.util;

import com.passql.submission.dto.AccuracyDetailResponse;
import com.passql.submission.dto.AccuracyDetailResponse.DifficultyStat;
import com.passql.submission.dto.QuestionAttemptRow;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 정답률 상세 집계 (#909): 난이도별 마지막 시도 정답률, 다시 맞힌 문제, 주별 남은 오답
 */
class AccuracyDetailCalculatorTest {

    // 2026-11-07 토요일 > 이번 주 시작 11-02(월)
    private static final LocalDate TODAY = LocalDate.of(2026, 11, 7);
    private static final UUID QUESTION_A = UUID.nameUUIDFromBytes("A".getBytes());
    private static final UUID QUESTION_B = UUID.nameUUIDFromBytes("B".getBytes());
    private static final UUID QUESTION_INACTIVE = UUID.nameUUIDFromBytes("C".getBytes());

    private static QuestionAttemptRow row(UUID questionUuid, boolean isCorrect, LocalDateTime submittedAt,
                                          int difficulty, boolean isActive) {
        return new QuestionAttemptRow(questionUuid, isCorrect, submittedAt, difficulty, isActive);
    }

    @Test
    void 난이도별_정답률은_문제별_마지막_시도이고_푼_단계만() {
        List<QuestionAttemptRow> rows = List.of(
            row(QUESTION_A, false, TODAY.atTime(9, 0), 2, true),
            row(QUESTION_A, true, TODAY.atTime(10, 0), 2, true),
            row(QUESTION_B, false, TODAY.atTime(11, 0), 2, true),
            row(QUESTION_INACTIVE, true, TODAY.atTime(12, 0), 9, false));

        AccuracyDetailResponse detail = AccuracyDetailCalculator.calculate(rows, TODAY);

        assertThat(detail.difficultyStats()).containsExactly(
            new DifficultyStat(2, 2, 0.5),
            new DifficultyStat(5, 1, 1.0));
    }

    @Test
    void 남은_오답은_주가_끝난_시점의_마지막_시도로_다시_세고_비활성_문제는_뺀다() {
        LocalDateTime lastWeek = LocalDate.of(2026, 10, 28).atTime(20, 0);
        List<QuestionAttemptRow> rows = List.of(
            row(QUESTION_A, false, lastWeek, 1, true),
            row(QUESTION_B, false, lastWeek.plusMinutes(1), 1, true),
            row(QUESTION_INACTIVE, false, lastWeek.plusMinutes(2), 1, false),
            row(QUESTION_A, true, TODAY.atTime(9, 0), 1, true));

        AccuracyDetailResponse detail = AccuracyDetailCalculator.calculate(rows, TODAY);

        assertThat(detail.everWrongQuestionCount()).isEqualTo(2);
        assertThat(detail.clearedWrongQuestionCount()).isEqualTo(1);
        assertThat(detail.remainingWrongTrend()).hasSize(8);
        assertThat(detail.remainingWrongTrend().get(6).weekStartDate()).isEqualTo(LocalDate.of(2026, 10, 26));
        assertThat(detail.remainingWrongTrend().get(6).remainingWrongCount()).isEqualTo(2);
        assertThat(detail.remainingWrongTrend().get(7).weekStartDate()).isEqualTo(LocalDate.of(2026, 11, 2));
        assertThat(detail.remainingWrongTrend().get(7).remainingWrongCount()).isEqualTo(1);
        assertThat(detail.remainingWrongTrend().get(0).remainingWrongCount()).isZero();
    }
}
