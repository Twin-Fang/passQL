package com.passql.question.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import org.junit.jupiter.api.Test;

/**
 * 보기 표시 순서: 번호·조합 보기는 저장 순서 유지 (#1155)
 */
class ChoiceOrderShufflerTest {

    // 섞기를 여러 번 돌려도 순서가 바뀌지 않아야 고정으로 판단 (우연히 같은 순서가 나올 확률 차단)
    private static final int REPEAT_COUNT = 30;

    @Test
    void 그림_표_번호_보기는_저장_순서를_유지한다() {
        assertOrderKept(List.of("① 의 그림", "② 의 그림", "③ 의 그림", "④ 의 그림"));
    }

    @Test
    void 조합형_보기는_저장_순서를_유지한다() {
        assertOrderKept(List.of("(가), (다)", "(가), (마)", "(나), (라)", "(다), (마)"));
        assertOrderKept(List.of("ㄱ, ㄴ", "ㄱ, ㄷ", "ㄴ, ㄹ", "ㄷ, ㄹ"));
    }

    @Test
    void 일반_문장_보기는_섞인다() {
        List<String> bodies = List.of("SELECT A", "SELECT B", "SELECT C", "SELECT D");
        boolean isEverShuffled = false;
        for (int attempt = 0; attempt < REPEAT_COUNT && !isEverShuffled; attempt++) {
            isEverShuffled = !ChoiceOrderShuffler.shuffle(bodies, body -> body, (body, order) -> body).equals(bodies);
        }
        assertThat(isEverShuffled).isTrue();
    }

    private void assertOrderKept(List<String> bodies) {
        for (int attempt = 0; attempt < REPEAT_COUNT; attempt++) {
            assertThat(ChoiceOrderShuffler.shuffle(bodies, body -> body, (body, order) -> body)).isEqualTo(bodies);
        }
    }
}
