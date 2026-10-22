package com.passql.application.service;

import com.passql.question.dto.RecommendationsResponse;
import com.passql.question.service.QuestionService;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 랜덤 풀기: 안 푼 문제 우선, 부족하면 푼 문제로 채움, size 는 1~10 */
class RandomPracticeServiceTest {

    private final QuestionService questionService = mock(QuestionService.class);
    private final SubmissionRepository submissionRepository = mock(SubmissionRepository.class);
    private final RandomPracticeService service = new RandomPracticeService(questionService, submissionRepository);

    private final UUID memberUuid = UUID.randomUUID();

    private static List<UUID> newQuestionUuids(int count) {
        return IntStream.range(0, count).mapToObj(index -> UUID.randomUUID()).toList();
    }

    /** 서비스가 요약 조회에 넘긴 문제 uuid 목록 */
    @SuppressWarnings("unchecked")
    private Set<String> capturePickedQuestionUuids() {
        ArgumentCaptor<List<String>> captor = ArgumentCaptor.forClass(List.class);
        verify(questionService).getRecommendationsByUuids(captor.capture());
        return Set.copyOf(captor.getValue());
    }

    private void givenQuestions(List<UUID> playable, List<UUID> submitted) {
        when(questionService.findPlayableActiveQuestionUuids()).thenReturn(playable);
        when(submissionRepository.findAllSubmittedQuestionUuids(memberUuid)).thenReturn(submitted);
        when(questionService.getRecommendationsByUuids(anyList())).thenReturn(new RecommendationsResponse(List.of()));
    }

    @Test
    void 안_푼_문제를_먼저_고르고_부족분만_푼_문제로_채운다() {
        List<UUID> unsolved = newQuestionUuids(4);
        List<UUID> solved = newQuestionUuids(20);
        givenQuestions(IntStream.range(0, 24).mapToObj(i -> i < 4 ? unsolved.get(i) : solved.get(i - 4)).toList(), solved);

        service.findRandomQuestions(memberUuid, 10);

        Set<String> picked = capturePickedQuestionUuids();
        assertThat(picked).hasSize(10);
        assertThat(picked).containsAll(unsolved.stream().map(UUID::toString).collect(Collectors.toSet()));
    }

    @Test
    void 안_푼_문제가_충분하면_푼_문제는_섞이지_않는다() {
        List<UUID> unsolved = newQuestionUuids(15);
        List<UUID> solved = newQuestionUuids(5);
        givenQuestions(java.util.stream.Stream.concat(unsolved.stream(), solved.stream()).toList(), solved);

        service.findRandomQuestions(memberUuid, 10);

        Set<String> picked = capturePickedQuestionUuids();
        assertThat(picked).hasSize(10);
        assertThat(picked).doesNotContainAnyElementsOf(solved.stream().map(UUID::toString).toList());
    }

    @Test
    void size_는_1에서_10으로_보정한다() {
        List<UUID> playable = newQuestionUuids(30);
        givenQuestions(playable, List.of());

        service.findRandomQuestions(memberUuid, 99);

        assertThat(capturePickedQuestionUuids()).hasSize(RandomPracticeService.MAX_SIZE);
    }
}
