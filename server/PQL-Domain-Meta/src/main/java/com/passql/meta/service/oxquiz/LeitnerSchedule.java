package com.passql.meta.service.oxquiz;

import java.time.LocalDate;

/**
 * OX 카드 간격 반복 (#1083, Leitner 5칸): 맞히면 칸 +1(최대 5), 틀리면 1칸 > 칸별 간격 뒤 날짜에 다시 출제
 * 처음 푸는 카드는 1칸에서 시작한 것으로 봄
 */
public final class LeitnerSchedule {

    public static final int FIRST_BOX = 1;
    public static final int LAST_BOX = 5;
    // 칸별 다음 출제 간격 (일): 1칸 1, 2칸 2, 3칸 4, 4칸 7, 5칸 14
    private static final int[] REVIEW_INTERVAL_DAYS_BY_BOX = {1, 2, 4, 7, 14};

    private LeitnerSchedule() {
    }

    /** 답한 뒤 칸과 다음 출제일 */
    public record NextReview(int box, LocalDate dueDate) {
    }

    /** 현재 칸(처음이면 null) + 정오 + 답한 날 > 다음 칸·출제일 */
    public static NextReview next(Integer currentBox, boolean isCorrect, LocalDate answeredDate) {
        int baseBox = currentBox == null ? FIRST_BOX : Math.min(Math.max(currentBox, FIRST_BOX), LAST_BOX);
        int nextBox = isCorrect ? Math.min(baseBox + 1, LAST_BOX) : FIRST_BOX;
        return new NextReview(nextBox, answeredDate.plusDays(REVIEW_INTERVAL_DAYS_BY_BOX[nextBox - 1]));
    }
}
