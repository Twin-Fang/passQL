package com.passql.submission.service;

import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.constant.WrongQuestionSort;
import com.passql.submission.dto.WrongQuestionHistory;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 오답 노트 고르기 (#1081): 최신 제출이 정답이면 정리됨 > 기본 제외, 과목 필터, 많이 틀린 순
 */
class WrongNoteSelectorTest {

    private static final LocalDateTime BASE_TIME = LocalDateTime.of(2026, 11, 16, 9, 0);

    private final WrongQuestionHistory resolvedModeling = history("data_modeling", 3, 1, true);
    private final WrongQuestionHistory openModeling = history("data_modeling", 1, 3, false);
    private final WrongQuestionHistory openSql = history("sql_basic", 5, 2, false);
    private final List<WrongQuestionHistory> histories = List.of(resolvedModeling, openModeling, openSql);

    @Test
    void 최신_제출이_정답인_문제는_정리됨이라_기본_목록에서_빠진다() {
        List<WrongQuestionHistory> selected = WrongNoteSelector.select(histories, null, WrongQuestionSort.RECENT, false);

        assertThat(resolvedModeling.isResolved()).isTrue();
        assertThat(selected).containsExactly(openModeling, openSql);
    }

    @Test
    void 정리된_문제도_보기면_포함한다() {
        List<WrongQuestionHistory> selected = WrongNoteSelector.select(histories, null, WrongQuestionSort.RECENT, true);

        assertThat(selected).containsExactly(openModeling, openSql, resolvedModeling);
    }

    @Test
    void 과목_필터와_많이_틀린_순() {
        assertThat(WrongNoteSelector.select(histories, MockExamSubject.SUBJECT_ONE, WrongQuestionSort.MOST_WRONG, true))
            .containsExactly(resolvedModeling, openModeling);
        assertThat(WrongNoteSelector.select(histories, null, WrongQuestionSort.MOST_WRONG, false))
            .containsExactly(openSql, openModeling);
    }

    // 마지막 오답 시각은 기준 시각 + hoursAfterBase (클수록 최근)
    private static WrongQuestionHistory history(String topicCode, int wrongCount, int hoursAfterBase, boolean isLatestCorrect) {
        return new WrongQuestionHistory(UUID.randomUUID(), "지문", "토픽", topicCode, wrongCount,
            BASE_TIME.plusHours(hoursAfterBase), isLatestCorrect);
    }
}
