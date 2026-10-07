package com.passql.web.ai;

import com.passql.ai.client.GeminiClient;
import com.passql.ai.dto.AiResult;
import com.passql.application.service.AiExplainService;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.service.PromptService;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionRepository;
import com.passql.submission.entity.Submission;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/** AI 해설이 항상 "일시적으로 사용 불가"로 나가던 문제(#354)의 회귀 테스트. */
class AiExplainServiceTest {

    private final GeminiClient gemini = mock(GeminiClient.class);
    private final PromptService prompts = mock(PromptService.class);
    private final QuestionRepository questions = mock(QuestionRepository.class);
    private final QuestionChoiceSetItemRepository items = mock(QuestionChoiceSetItemRepository.class);
    private final SubmissionRepository submissions = mock(SubmissionRepository.class);
    @SuppressWarnings("unchecked")
    private final RedisTemplate<String, Object> redis = mock(RedisTemplate.class);
    @SuppressWarnings("unchecked")
    private final ValueOperations<String, Object> ops = mock(ValueOperations.class);

    private final AiExplainService service =
            new AiExplainService(gemini, prompts, questions, items, submissions, redis);

    private final UUID member = UUID.randomUUID();
    private final UUID qid = UUID.randomUUID();
    private final UUID setId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        when(redis.opsForValue()).thenReturn(ops);
        PromptTemplate p = PromptTemplate.builder().keyName("diff_explain").version(1).model("m")
                .systemPrompt("튜터\\n입니다").userTemplate("").temperature(0.5f).maxTokens(512).build();
        when(prompts.getActivePrompt(anyString())).thenReturn(p);
        when(questions.findById(qid)).thenReturn(Optional.of(Question.builder()
                .questionUuid(qid).stem("RANK 결과는?").schemaDdl("CREATE TABLE EMP(...)").build()));
    }

    private QuestionChoiceSetItem item(String key, String body, boolean correct) {
        return QuestionChoiceSetItem.builder().choiceSetUuid(setId).choiceKey(key).body(body).isCorrect(correct).build();
    }

    @Test
    void 마지막_제출의_선택지_세트로_고른_답과_정답을_비교해_해설한다() {
        when(submissions.findFirstByMemberUuidAndQuestionUuidOrderBySubmittedAtDesc(member, qid))
                .thenReturn(Optional.of(Submission.builder().choiceSetUuid(setId).selectedChoiceKey("C").build()));
        when(items.findByChoiceSetUuidOrderBySortOrderAsc(setId)).thenReturn(List.of(
                item("A", "정답 결과표", true), item("C", "오답 결과표", false)));
        when(gemini.chat(anyString(), anyString(), anyString(), anyFloat(), anyInt())).thenReturn("  C는 동점 처리가 다릅니다.  ");

        AiResult r = service.diffExplain(member, qid, "C");

        assertEquals("C는 동점 처리가 다릅니다.", r.text());
        ArgumentCaptor<String> sys = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<String> user = ArgumentCaptor.forClass(String.class);
        verify(gemini).chat(anyString(), sys.capture(), user.capture(), anyFloat(), anyInt());
        assertEquals("튜터\n입니다", sys.getValue(), "DB 프롬프트의 '\\n' 글자를 줄바꿈으로 바꾼다");
        assertTrue(user.getValue().contains("오답 결과표"));
        assertTrue(user.getValue().contains("정답 결과표"));
        assertTrue(user.getValue().contains("왜 답이 아닌지"));
        assertTrue(user.getValue().contains("선택지 전체"), "전체 선택지를 넘겨 결과를 비교하게 한다");
        assertTrue(user.getValue().contains("옳지 않은 것"), "문제 방향 규칙을 붙인다");
        verify(ops).set(anyString(), eq("C는 동점 처리가 다릅니다."), anyLong(), any());
    }

    @Test
    void 캐시에_있으면_AI를_다시_부르지_않는다() {
        when(submissions.findFirstByMemberUuidAndQuestionUuidOrderBySubmittedAtDesc(member, qid)).thenReturn(Optional.empty());
        when(ops.get(anyString())).thenReturn("캐시된 해설");

        assertEquals("캐시된 해설", service.diffExplain(member, qid, "B").text());
        verify(gemini, never()).chat(anyString(), anyString(), anyString(), anyFloat(), anyInt());
    }

    @Test
    void 실행_오류_해설은_SQL과_오류_메시지를_넘긴다() {
        when(gemini.chat(anyString(), anyString(), anyString(), anyFloat(), anyInt())).thenReturn("컬럼명이 틀렸습니다.");

        AiResult r = service.explainError(member, qid, "SELECT ENAM FROM EMP", "column \"enam\" does not exist");

        assertEquals("컬럼명이 틀렸습니다.", r.text());
        ArgumentCaptor<String> user = ArgumentCaptor.forClass(String.class);
        verify(gemini).chat(anyString(), anyString(), user.capture(), anyFloat(), anyInt());
        assertTrue(user.getValue().contains("SELECT ENAM FROM EMP"));
        assertTrue(user.getValue().contains("does not exist"));
    }

    @Test
    void AI_호출이_실패하면_AI_UNAVAILABLE_로_알린다() {
        when(gemini.chat(anyString(), anyString(), anyString(), anyFloat(), anyInt())).thenThrow(new RuntimeException("quota"));

        CustomException e = assertThrows(CustomException.class, () -> service.explainError(member, qid, "x", "y"));
        assertEquals(ErrorCode.AI_UNAVAILABLE, e.getErrorCode());
    }
}
