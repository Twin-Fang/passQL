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
 * 번호·기호로 시작하는 보기(그림·표 ①~④, 조합 (가)·ㄱ)는 저장 순서 유지 (그림 번호 <-> 보기 자리 일치, #1155)
 */
public final class ChoiceOrderShuffler {

    // 숫자 보기 판별: 정수·소수, 앞뒤 공백 허용
    private static final Pattern NUMERIC_BODY = Pattern.compile("^\\s*-?\\d+(\\.\\d+)?\\s*$");
    // 순서 고정 보기: ①~④ 그림·표 번호, (가)~(하) 조합, ㄱ~ㅎ 조합 (ㄱ, ㄴ / ㄱ ㄴ)
    private static final Pattern FIXED_ORDER_BODY = Pattern.compile("^\\s*([①②③④⑤]|\\([가-하]\\)|[ㄱ-ㅎ](\\s|,|$))");

    private ChoiceOrderShuffler() {
    }

    /** 보기 목록 > 표시 순서 목록 (bodyOf: 보기 본문, withSortOrder: 보기와 새 순번으로 표시용 보기 생성) */
    public static <T> List<T> shuffle(List<T> choices, Function<T, String> bodyOf, BiFunction<T, Integer, T> withSortOrder) {
        List<T> orderedChoices = new ArrayList<>(choices);
        if (isAllNumeric(choices, bodyOf)) {
            orderedChoices.sort(Comparator.comparing(choice -> new BigDecimal(bodyOf.apply(choice).trim())));
        } else if (hasFixedOrderBody(choices, bodyOf)) {
            // 저장 순서 그대로 (입력 목록 = sortOrder 순)
        } else {
            Collections.shuffle(orderedChoices);
        }
        List<T> renumberedChoices = new ArrayList<>(orderedChoices.size());
        for (int index = 0; index < orderedChoices.size(); index++) {
            renumberedChoices.add(withSortOrder.apply(orderedChoices.get(index), index + 1));
        }
        return renumberedChoices;
    }

    private static <T> boolean hasFixedOrderBody(List<T> choices, Function<T, String> bodyOf) {
        return choices.stream()
                .map(bodyOf)
                .anyMatch(body -> body != null && FIXED_ORDER_BODY.matcher(body).find());
    }

    private static <T> boolean isAllNumeric(List<T> choices, Function<T, String> bodyOf) {
        return !choices.isEmpty() && choices.stream()
                .map(bodyOf)
                .allMatch(body -> body != null && NUMERIC_BODY.matcher(body).matches());
    }
}
