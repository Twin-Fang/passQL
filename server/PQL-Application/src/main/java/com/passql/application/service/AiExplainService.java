package com.passql.application.service;

import com.passql.ai.client.GeminiClient;
import com.passql.ai.dto.AiResult;
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
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * 문제 풀이 AI 해설.
 *
 * - diffExplain: 회원이 고른 선택지가 왜 틀렸는지(또는 왜 맞는지)를 정답과 비교해 설명한다.
 * - explainError: 회원이 실행한 SQL 의 오류 원인과 고치는 방법을 설명한다.
 *
 * Python AI 서버를 거치지 않고 이미 운영 중인 Gemini 직접 호출(AiCommentService 와 같은 방식)을 쓴다.
 * 프롬프트는 DB(prompt_template)의 'diff_explain'·'explain_error' 활성 버전을 쓰므로 관리자 화면에서 바꿀 수 있다.
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AiExplainService {

    private static final String PROMPT_DIFF = "diff_explain";
    private static final String PROMPT_ERROR = "explain_error";
    private static final String CACHE_PREFIX = "ai-explain:";
    // 같은 문제·같은 선택은 해설이 같으므로 하루 동안 재사용해 호출 비용을 줄인다.
    private static final long CACHE_TTL_HOURS = 24;

    /** 해설 형식 지시. DB 프롬프트 뒤에 붙여 모바일에서 읽기 좋은 길이로 맞춘다. */
    private static final String FORMAT_GUIDE = """

            [답변 형식]
            - 한국어, 마크다운 사용 가능
            - 핵심 원인 1~2문장 → 정답이 맞는 이유 → 기억할 포인트 순서
            - 600자 이내, 불필요한 인사말 없이""";

    private final GeminiClient geminiClient;
    private final PromptService promptService;
    private final QuestionRepository questionRepository;
    private final QuestionChoiceSetItemRepository choiceSetItemRepository;
    private final SubmissionRepository submissionRepository;
    private final RedisTemplate<String, Object> redisTemplate;

    public AiResult diffExplain(UUID memberUuid, UUID questionUuid, String selectedChoiceKey) {
        Question question = questionRepository.findById(questionUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.QUESTION_NOT_FOUND));

        // 선택지는 풀이마다 새로 생성되므로, 회원이 실제로 본 세트를 마지막 제출에서 찾는다.
        Optional<Submission> last = submissionRepository
                .findFirstByMemberUuidAndQuestionUuidOrderBySubmittedAtDesc(memberUuid, questionUuid);
        UUID choiceSetUuid = last.map(Submission::getChoiceSetUuid).orElse(null);
        String selectedKey = selectedChoiceKey != null ? selectedChoiceKey : last.map(Submission::getSelectedChoiceKey).orElse(null);

        List<QuestionChoiceSetItem> items = choiceSetUuid == null ? List.of()
                : choiceSetItemRepository.findByChoiceSetUuidOrderBySortOrderAsc(choiceSetUuid);
        QuestionChoiceSetItem selected = items.stream()
                .filter(i -> i.getChoiceKey().equals(selectedKey)).findFirst().orElse(null);
        QuestionChoiceSetItem correct = items.stream()
                .filter(i -> Boolean.TRUE.equals(i.getIsCorrect())).findFirst().orElse(null);

        String cacheKey = CACHE_PREFIX + "diff:" + questionUuid + ":" + choiceSetUuid + ":" + selectedKey;
        String cached = readCache(cacheKey);
        if (cached != null) return new AiResult(cached, 0);

        PromptTemplate prompt = promptService.getActivePrompt(PROMPT_DIFF);
        String userPrompt = buildDiffPrompt(question, selected, correct, selectedKey);
        String text = call(prompt, userPrompt, "diffExplain", questionUuid);
        writeCache(cacheKey, text);
        return new AiResult(text, prompt.getVersion());
    }

    public AiResult explainError(UUID memberUuid, UUID questionUuid, String sql, String errorMessage) {
        Question question = questionRepository.findById(questionUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.QUESTION_NOT_FOUND));

        String cacheKey = CACHE_PREFIX + "error:" + questionUuid + ":" + Integer.toHexString((sql + "|" + errorMessage).hashCode());
        String cached = readCache(cacheKey);
        if (cached != null) return new AiResult(cached, 0);

        PromptTemplate prompt = promptService.getActivePrompt(PROMPT_ERROR);
        String userPrompt = """
                문제: %s

                테이블 구조:
                %s

                학습자가 실행한 SQL:
                %s

                발생한 오류:
                %s

                오류가 난 원인과 고치는 방법을 설명해 주세요.
                """.formatted(nz(question.getStem()), nz(question.getSchemaDdl()), nz(sql), nz(errorMessage))
                + FORMAT_GUIDE;
        String text = call(prompt, userPrompt, "explainError", questionUuid);
        writeCache(cacheKey, text);
        return new AiResult(text, prompt.getVersion());
    }

    /** 고른 답과 정답을 함께 보여 주고 비교 해설을 요청한다. 세트를 못 찾으면 문제 정보만으로 설명한다. */
    private String buildDiffPrompt(Question q, QuestionChoiceSetItem selected, QuestionChoiceSetItem correct, String selectedKey) {
        StringBuilder sb = new StringBuilder();
        sb.append("문제: ").append(nz(q.getStem())).append("\n\n");
        if (q.getSchemaDdl() != null && !q.getSchemaDdl().isBlank()) {
            sb.append("테이블 구조:\n").append(q.getSchemaDdl()).append("\n\n");
        }
        if (q.getAnswerSql() != null && !q.getAnswerSql().isBlank()) {
            sb.append("정답 SQL:\n").append(q.getAnswerSql()).append("\n\n");
        }
        if (selected != null) {
            sb.append("학습자가 고른 선택지(").append(selected.getChoiceKey()).append("):\n")
              .append(nz(selected.getBody())).append("\n\n");
        } else if (selectedKey != null) {
            sb.append("학습자가 고른 선택지: ").append(selectedKey).append("\n\n");
        }
        if (correct != null) {
            sb.append("정답 선택지(").append(correct.getChoiceKey()).append("):\n")
              .append(nz(correct.getBody())).append("\n");
            if (correct.getRationale() != null && !correct.getRationale().isBlank()) {
                sb.append("정답 근거(참고): ").append(correct.getRationale()).append("\n");
            }
            sb.append("\n");
        }
        boolean isCorrect = selected != null && correct != null && selected.getChoiceKey().equals(correct.getChoiceKey());
        sb.append(isCorrect
                ? "학습자는 정답을 골랐습니다. 이 선택지가 왜 맞는지, 다른 선택지와 무엇이 다른지 설명해 주세요."
                : "학습자가 고른 선택지가 왜 틀렸는지, 정답 선택지가 왜 맞는지 비교해서 설명해 주세요.");
        return sb + FORMAT_GUIDE;
    }

    private String call(PromptTemplate prompt, String userPrompt, String kind, UUID questionUuid) {
        try {
            String text = geminiClient.chat(
                    prompt.getModel(),
                    // DB 프롬프트에 줄바꿈이 '\n' 글자로 저장된 경우가 있어 실제 줄바꿈으로 바꾼다.
                    prompt.getSystemPrompt().replace("\\n", "\n"),
                    userPrompt,
                    prompt.getTemperature() != null ? prompt.getTemperature() : 0.5f,
                    prompt.getMaxTokens() != null ? Math.max(prompt.getMaxTokens(), 768) : 768);
            if (text == null || text.isBlank()) throw new IllegalStateException("빈 응답");
            return text.trim();
        } catch (Exception e) {
            log.error("[ai-explain] {} 실패: question={}", kind, questionUuid, e);
            throw new CustomException(ErrorCode.AI_UNAVAILABLE);
        }
    }

    private String readCache(String key) {
        try {
            Object v = redisTemplate.opsForValue().get(key);
            return v instanceof String s ? s : null;
        } catch (Exception e) {
            // 캐시 장애는 해설 자체를 막지 않는다.
            log.warn("[ai-explain] 캐시 조회 실패: {}", e.getMessage());
            return null;
        }
    }

    private void writeCache(String key, String value) {
        try {
            redisTemplate.opsForValue().set(key, value, CACHE_TTL_HOURS, TimeUnit.HOURS);
        } catch (Exception e) {
            log.warn("[ai-explain] 캐시 저장 실패: {}", e.getMessage());
        }
    }

    private static String nz(String s) {
        return s == null ? "" : s;
    }
}
