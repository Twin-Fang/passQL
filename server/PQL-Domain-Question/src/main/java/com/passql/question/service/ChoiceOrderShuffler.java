package com.passql.question.service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.function.BiFunction;

/**
 * 고정 보기 표시 순서 섞기: 입력 복사 > 무작위 섞기 > 표시 순번 1..N 재부여 (DB 값 불변, #511)
 * 채점은 choiceKey 기준이라 순서와 무관
 */
public final class ChoiceOrderShuffler {

    private ChoiceOrderShuffler() {
    }

    /** 보기 목록 > 섞인 새 목록 (withSortOrder: 보기와 새 순번으로 표시용 보기 생성) */
    public static <T> List<T> shuffle(List<T> choices, BiFunction<T, Integer, T> withSortOrder) {
        List<T> shuffledChoices = new ArrayList<>(choices);
        Collections.shuffle(shuffledChoices);
        List<T> renumberedChoices = new ArrayList<>(shuffledChoices.size());
        for (int index = 0; index < shuffledChoices.size(); index++) {
            renumberedChoices.add(withSortOrder.apply(shuffledChoices.get(index), index + 1));
        }
        return renumberedChoices;
    }
}
