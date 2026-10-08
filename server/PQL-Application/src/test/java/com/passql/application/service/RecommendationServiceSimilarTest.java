package com.passql.application.service;

import com.passql.ai.client.AiGatewayClient;
import com.passql.ai.dto.RecommendRequest;
import com.passql.ai.dto.RecommendResult;
import com.passql.ai.dto.SimilarQuestion;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.dto.QuestionSummary;
import com.passql.question.dto.RecommendationsResponse;
import com.passql.question.service.QuestionService;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 유사 문제 (#442) — 결과 화면 보조 섹션이라 어떤 실패도 500 이 아니라 빈 목록이어야 한다. */
class RecommendationServiceSimilarTest {

    private final AiGatewayClient ai = mock(AiGatewayClient.class);
    private final QuestionService questions = mock(QuestionService.class);
    private final RecommendationService service =
            new RecommendationService(ai, mock(SubmissionRepository.class), questions);

    private final UUID base = UUID.randomUUID();
    private final UUID a = UUID.randomUUID();
    private final UUID b = UUID.randomUUID();

    private static QuestionSummary summary(UUID id, String stem) {
        return new QuestionSummary(id, "WINDOW", "윈도우 함수", 2, ExecutionMode.EXECUTABLE, stem, null);
    }

    @Test
    void 기준_문제_벡터로_검색하고_자기자신은_제외하며_점수를_붙인다() {
        when(ai.recommend(any())).thenReturn(new RecommendResult(List.of(
                new RecommendResult.RecommendedQuestion(a.toString(), 0.91),
                new RecommendResult.RecommendedQuestion(b.toString(), 0.83)), 1));
        when(questions.getRecommendationsByUuids(List.of(a.toString(), b.toString())))
                .thenReturn(new RecommendationsResponse(List.of(summary(a, "RANK 문제"), summary(b, "ROW_NUMBER 문제"))));

        List<SimilarQuestion> result = service.findSimilar(base, 3);

        ArgumentCaptor<RecommendRequest> req = ArgumentCaptor.forClass(RecommendRequest.class);
        verify(ai).recommend(req.capture());
        assertThat(req.getValue().size()).isEqualTo(3);
        assertThat(req.getValue().recentWrongQuestionUuids()).containsExactly(base.toString());
        assertThat(req.getValue().solvedQuestionUuids()).containsExactly(base.toString());
        assertThat(result).extracting(SimilarQuestion::questionUuid).containsExactly(a, b);
        assertThat(result.get(0).score()).isEqualTo(0.91);
        assertThat(result.get(0).stem()).isEqualTo("RANK 문제");
        assertThat(result.get(0).topicName()).isEqualTo("윈도우 함수");
    }

    @Test
    void 개수는_1에서_5로_보정한다() {
        when(ai.recommend(any())).thenReturn(new RecommendResult(List.of(), 0));
        service.findSimilar(base, 99);
        ArgumentCaptor<RecommendRequest> req = ArgumentCaptor.forClass(RecommendRequest.class);
        verify(ai).recommend(req.capture());
        assertThat(req.getValue().size()).isEqualTo(5);
    }

    @Test
    void 색인_안됨_또는_AI_실패는_빈_목록() {
        when(ai.recommend(any())).thenReturn(new RecommendResult(List.of(), 0));
        assertThat(service.findSimilar(base, 3)).isEmpty();

        when(ai.recommend(any())).thenThrow(new RuntimeException("AI 서버 연결 실패"));
        assertThat(service.findSimilar(base, 3)).isEmpty();
    }
}
