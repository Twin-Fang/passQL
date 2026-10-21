package com.passql.question.service;

import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 고정 보기 순서 섞기: 보기 집합 유지, 표시 순번 1..N 재부여, 실제로 순서가 바뀜 (#511), 숫자 보기는 오름차순 (#565)
 */
class ChoiceOrderShufflerTest {

    private record Choice(String choiceKey, int sortOrder, String body) {
        Choice(String choiceKey, int sortOrder) {
            this(choiceKey, sortOrder, "보기 " + choiceKey);
        }
    }

    private final List<Choice> choices = List.of(
            new Choice("A", 0), new Choice("B", 1), new Choice("C", 2), new Choice("D", 3));

    @Test
    void shuffle_keepsChoiceKeysAndRenumbersSortOrder() {
        List<Choice> shuffled = ChoiceOrderShuffler.shuffle(choices, Choice::body,
                (choice, sortOrder) -> new Choice(choice.choiceKey(), sortOrder));

        assertThat(shuffled).extracting(Choice::choiceKey).containsExactlyInAnyOrder("A", "B", "C", "D");
        assertThat(shuffled).extracting(Choice::sortOrder).containsExactly(1, 2, 3, 4);
    }

    @Test
    void shuffle_changesOrderAcrossCalls() {
        boolean hasDifferentOrder = false;
        for (int attempt = 0; attempt < 100 && !hasDifferentOrder; attempt++) {
            List<String> keys = ChoiceOrderShuffler.shuffle(choices, Choice::body,
                            (choice, sortOrder) -> new Choice(choice.choiceKey(), sortOrder))
                    .stream().map(Choice::choiceKey).toList();
            hasDifferentOrder = !keys.equals(List.of("A", "B", "C", "D"));
        }
        assertThat(hasDifferentOrder).isTrue();
    }

    @Test
    void 숫자_보기는_섞지_않고_오름차순으로_둔다() {
        List<Choice> numericChoices = List.of(
                new Choice("A", 0, "3"), new Choice("B", 1, "1"), new Choice("C", 2, "10"), new Choice("D", 3, "2"));
        for (int attempt = 0; attempt < 20; attempt++) {
            List<String> bodies = ChoiceOrderShuffler.shuffle(numericChoices, Choice::body,
                            (choice, sortOrder) -> new Choice(choice.choiceKey(), sortOrder, choice.body()))
                    .stream().map(Choice::body).toList();
            assertThat(bodies).containsExactly("1", "2", "3", "10");
        }
    }

    @Test
    void shuffle_doesNotMutateInput() {
        ChoiceOrderShuffler.shuffle(choices, Choice::body, (choice, sortOrder) -> new Choice(choice.choiceKey(), sortOrder));

        assertThat(choices).extracting(Choice::choiceKey).containsExactly("A", "B", "C", "D");
    }
}
