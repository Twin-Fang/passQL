package com.passql.submission.service;

import com.passql.submission.constant.ExamAnswerItemStatus;
import com.passql.submission.entity.ExamAnswerItem;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 표시용 정답 핵심 판정 (#1101): 갈림 문항은 운영 후보 답 표시 + 미확정(점수 범위), 모름은 득표 1위
 */
class ExamAnswerKeyResolverTest {

    // 득표: 보기 2번 1표 (인덱스 1~4)
    private static final int[] ONE_VOTE_FOR_CHOICE_TWO = {0, 0, 1, 0, 0};
    private static final int[] NO_VOTES = {0, 0, 0, 0, 0};

    @Test
    void 갈림_문항은_득표가_없어도_운영_후보_답을_보여_주고_확정하지_않는다() {
        ExamAnswerKey key = ExamAnswerKeyResolver.resolve(item(ExamAnswerItemStatus.DISPUTED, 3), NO_VOTES);

        assertThat(key.answer()).isEqualTo(3);
        assertThat(key.isDetermined()).isFalse();
    }

    @Test
    void 갈림_문항은_득표_1위보다_운영_후보_답이_우선이다() {
        ExamAnswerKey key = ExamAnswerKeyResolver.resolve(item(ExamAnswerItemStatus.DISPUTED, 3), ONE_VOTE_FOR_CHOICE_TWO);

        assertThat(key.answer()).isEqualTo(3);
    }

    @Test
    void 모름_문항은_운영_답이_있어도_득표_1위를_보여_준다() {
        ExamAnswerKey key = ExamAnswerKeyResolver.resolve(item(ExamAnswerItemStatus.UNKNOWN, 3), ONE_VOTE_FOR_CHOICE_TWO);

        assertThat(key.answer()).isEqualTo(2);
        assertThat(key.isDetermined()).isFalse();
    }

    /** 2과목 11번 문항 (상태, 운영 답) */
    private static ExamAnswerItem item(ExamAnswerItemStatus status, Integer operatorAnswer) {
        return ExamAnswerItem.builder().questionNo(11).subjectNo(2)
                .operatorAnswerStatus(status).operatorAnswer(operatorAnswer).build();
    }
}
