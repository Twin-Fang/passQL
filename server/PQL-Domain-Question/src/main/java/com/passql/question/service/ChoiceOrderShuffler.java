package com.passql.question.service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.function.BiFunction;
import java.util.function.Function;
import java.util.regex.Pattern;

/**
 * 고정 보기 표시 순서 섞기: 입력 복사 > 무작위 섞기 > 표시 순번 1..N 재부여 (DB 값 불변, #511)
 * 보기가 모두 숫자면 섞지 않고 오름차순 (시험 관례, 배치로 정답 단서 차단, #565). 채점은 choiceKey 기준이라 순서와 무관
 */
public final class ChoiceOrderShuffler {

    // 숫자 보기 판별: 정수·소수, 앞뒤 공백 허용
    private static final Pattern NUMERIC_BODY = Pattern.compile("^\\s*-?\\d+(\\.\\d+)?\\s*$");

    private ChoiceOrderShuffler() {
    }

    /** 보기 목록 > 표시 순서 목록 (bodyOf: 보기 본문, withSortOrder: 보기와 새 순번으로 표시용 보기 생성) */
    public static <T> List<T> shuffle(List<T> choices, Function<T, String> bodyOf, BiFunction<T, Integer, T> withSortOrder) {
        List<T> orderedChoices = new ArrayList<>(choices);
        if (isAllNumeric(choices, bodyOf)) {
            orderedChoices.sort(Comparator.comparing(choice -> new BigDecimal(bodyOf.apply(choice).trim())));
        } else {
            Collections.shuffle(orderedChoices);
        }
        List<T> renumberedChoices = new ArrayList<>(orderedChoices.size());
        for (int index = 0; index < orderedChoices.size(); index++) {
            renumberedChoices.add(withSortOrder.apply(orderedChoices.get(index), index + 1));
        }
        return renumberedChoices;
    }

    private static <T> boolean isAllNumeric(List<T> choices, Function<T, String> bodyOf) {
        return !choices.isEmpty() && choices.stream()
                .map(bodyOf)
                .allMatch(body -> body != null && NUMERIC_BODY.matcher(body).matches());
    }
}
