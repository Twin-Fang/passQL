package com.passql.submission.service;

import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.constant.WrongQuestionSort;
import com.passql.submission.dto.WrongQuestionHistory;

import java.util.Comparator;
import java.util.List;

/**
 * 오답 노트 고르기 (#1081): 과목 필터 > 정리됨 제외(요청 시 포함) > 정렬
 * 정리됨 = 문제별 최신 제출이 정답 (WrongQuestionHistory.isResolved)
 */
public final class WrongNoteSelector {

    // 최근 틀린 순 (같으면 많이 틀린 순)
    private static final Comparator<WrongQuestionHistory> RECENT_ORDER =
        Comparator.comparing(WrongQuestionHistory::lastWrongAt, Comparator.nullsLast(Comparator.reverseOrder()))
            .thenComparing(Comparator.comparingInt(WrongQuestionHistory::wrongCount).reversed());

    // 많이 틀린 순 (같으면 최근 틀린 순)
    private static final Comparator<WrongQuestionHistory> MOST_WRONG_ORDER =
        Comparator.comparingInt(WrongQuestionHistory::wrongCount).reversed()
            .thenComparing(WrongQuestionHistory::lastWrongAt, Comparator.nullsLast(Comparator.reverseOrder()));

    private WrongNoteSelector() {
    }

    /** 오답 이력 > 보여 줄 순서의 목록 (subject null 이면 전체 과목, 개수 제한은 호출부) */
    public static List<WrongQuestionHistory> select(
        List<WrongQuestionHistory> histories,
        MockExamSubject subject,
        WrongQuestionSort sort,
        boolean isResolvedIncluded
    ) {
        return histories.stream()
            .filter(history -> subject == null || history.subject() == subject)
            .filter(history -> isResolvedIncluded || !history.isResolved())
            .sorted(sort == WrongQuestionSort.MOST_WRONG ? MOST_WRONG_ORDER : RECENT_ORDER)
            .toList();
    }
}
