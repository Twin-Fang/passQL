package com.passql.submission.service;

import com.passql.question.entity.Question;
import com.passql.question.event.CuratedChoiceSetReplacedEvent;
import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.dto.mockexam.AdminMockExamPublishCheck;
import com.passql.submission.entity.MockExamRoundItem;
import com.passql.submission.repository.MockExamRoundItemRepository;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * 고정 세트 교체 > 회차 문항 새 세트 재연결 > 공개 검사 통과, 다른 문제 문항은 그대로 (#1155)
 */
class MockExamRoundItemChoiceSetRepointListenerTest {

    private final MockExamRoundItemRepository roundItemRepository = mock(MockExamRoundItemRepository.class);
    private final MockExamRoundItemChoiceSetRepointListener listener =
        new MockExamRoundItemChoiceSetRepointListener(roundItemRepository);
    private final MockExamEligibleSetFinder eligibleSetFinder = mock(MockExamEligibleSetFinder.class);
    private final MockExamPublishChecker publishChecker = new MockExamPublishChecker(eligibleSetFinder);

    @Test
    void 회차에_든_문제의_세트를_교체하면_문항이_새_세트를_가리키고_공개_검사를_통과한다() {
        List<MockExamRoundItem> items = fiftyItemsOfOneRound();
        MockExamRoundItem replacedItem = items.get(0);
        MockExamRoundItem untouchedItem = items.get(1);
        UUID oldChoiceSetUuid = replacedItem.getChoiceSetUuid();
        UUID untouchedChoiceSetUuid = untouchedItem.getChoiceSetUuid();
        UUID newChoiceSetUuid = UUID.randomUUID();
        // 출제 가능 세트: 새 세트 + 다른 문항 세트 (옛 세트는 비활성이라 빠짐)
        Set<UUID> eligibleSetUuids = new HashSet<>(items.stream().map(MockExamRoundItem::getChoiceSetUuid).toList());
        eligibleSetUuids.remove(oldChoiceSetUuid);
        eligibleSetUuids.add(newChoiceSetUuid);
        stubEligibleSets(eligibleSetUuids);
        MockExamPaper paper = paperOf(items);
        assertThat(publishChecker.check(paper).canPublish()).isFalse();

        when(roundItemRepository.findByQuestionUuid(replacedItem.getQuestionUuid())).thenReturn(List.of(replacedItem));
        listener.onCuratedChoiceSetReplaced(new CuratedChoiceSetReplacedEvent(
            replacedItem.getQuestionUuid(), List.of(oldChoiceSetUuid), newChoiceSetUuid));

        assertThat(replacedItem.getChoiceSetUuid()).isEqualTo(newChoiceSetUuid);
        assertThat(untouchedItem.getChoiceSetUuid()).isEqualTo(untouchedChoiceSetUuid);
        AdminMockExamPublishCheck publishCheck = publishChecker.check(paper);
        assertThat(publishCheck.errors()).isEmpty();
        assertThat(publishCheck.canPublish()).isTrue();
    }

    @Test
    void 회차에_없는_문제의_세트를_교체하면_아무_문항도_바꾸지_않는다() {
        List<MockExamRoundItem> items = fiftyItemsOfOneRound();
        Map<UUID, UUID> choiceSetUuidByItemUuid = items.stream()
            .collect(Collectors.toMap(MockExamRoundItem::getMockExamRoundItemUuid, MockExamRoundItem::getChoiceSetUuid));
        UUID questionOutsideRounds = UUID.randomUUID();
        when(roundItemRepository.findByQuestionUuid(questionOutsideRounds)).thenReturn(List.of());

        listener.onCuratedChoiceSetReplaced(new CuratedChoiceSetReplacedEvent(
            questionOutsideRounds, List.of(UUID.randomUUID()), UUID.randomUUID()));

        items.forEach(item -> assertThat(item.getChoiceSetUuid())
            .isEqualTo(choiceSetUuidByItemUuid.get(item.getMockExamRoundItemUuid())));
    }

    @SuppressWarnings("unchecked")
    private void stubEligibleSets(Set<UUID> eligibleSetUuids) {
        when(eligibleSetFinder.findEligibleSetUuidsAmong(any(Collection.class))).thenAnswer(invocation -> {
            Collection<UUID> requested = invocation.getArgument(0);
            return requested.stream().filter(eligibleSetUuids::contains).collect(Collectors.toSet());
        });
    }

    // 1과목 10 + 2과목 40, 번호 1~50, 문제·세트 모두 다름
    private static List<MockExamRoundItem> fiftyItemsOfOneRound() {
        UUID roundUuid = UUID.randomUUID();
        List<MockExamRoundItem> items = new ArrayList<>();
        for (int questionNumber = 1; questionNumber <= MockExamRule.TOTAL_QUESTION_COUNT; questionNumber++) {
            MockExamSubject subject = questionNumber <= MockExamSubject.SUBJECT_ONE.getQuestionCount()
                ? MockExamSubject.SUBJECT_ONE : MockExamSubject.SUBJECT_TWO;
            items.add(MockExamRoundItem.builder()
                .mockExamRoundItemUuid(UUID.randomUUID())
                .mockExamRoundUuid(roundUuid)
                .questionNumber(questionNumber)
                .subject(subject)
                .topicUuid(UUID.randomUUID())
                .questionUuid(UUID.randomUUID())
                .choiceSetUuid(UUID.randomUUID())
                .build());
        }
        return items;
    }

    private static MockExamPaper paperOf(List<MockExamRoundItem> items) {
        Map<UUID, Question> questionByUuid = items.stream()
            .map(item -> Question.builder().questionUuid(item.getQuestionUuid()).stem("문제").isActive(true).build())
            .collect(Collectors.toMap(Question::getQuestionUuid, Function.identity()));
        return new MockExamPaper(null, items, questionByUuid, Map.of(), Map.of());
    }
}
