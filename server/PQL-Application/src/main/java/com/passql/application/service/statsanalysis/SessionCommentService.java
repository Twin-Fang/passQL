package com.passql.application.service.statsanalysis;

import com.passql.ai.client.AiChatClient;
import com.passql.application.service.statsanalysis.SessionCommentPlanner.SessionCommentPlan;
import com.passql.application.service.statsanalysis.SessionCommentPlanner.SessionResult;
import com.passql.application.service.statsanalysis.StatsAnalysisPromptFormatter.WrongQuestionSummary;
import com.passql.meta.constant.PromptKey;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.service.PromptService;
import com.passql.submission.repository.StatsAnalysisQueryRepository;
import com.passql.submission.repository.SubmissionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 결과 화면 세션 코멘트 (#862): 세션 결과 조회 > 서버 문장(점수·놓친 토픽·토픽 판정) > 오답 있으면 LLM 한 문장 > 평문
 * LLM·해석 실패(프롬프트 없음 포함)는 서버 문장만 응답 (5xx 없음), 이때 캐시하지 않음
 */
@Slf4j
@Service
@RequiredArgsConstructor
// 클래스 단위 트랜잭션 없음: LLM 호출 동안 DB 커넥션을 잡지 않게 (#497)
public class SessionCommentService {

    // LLM 에 넘길 세션 오답 최대 건수
    private static final int MAX_SESSION_WRONG_COUNT = 8;

    private final SubmissionRepository submissionRepository;
    private final StatsAnalysisQueryRepository statsAnalysisQueryRepository;
    private final StatsAnalysisDataLoader statsAnalysisDataLoader;
    private final PromptService promptService;
    private final AiChatClient aiChatClient;

    /** 세션 코멘트 평문 + 캐시 여부 (LLM 을 불렀다 실패했으면 캐시하지 않음) */
    public record SessionCommentResult(String comment, boolean isCacheable) {}

    /** 본인 세션 결과 > 서버 문장 > (오답 있으면) LLM 한 문장 (남의 세션·없는 세션은 고정 문장, 캐시 안 함) */
    public SessionCommentResult comment(UUID memberUuid, UUID sessionUuid) {
        List<SessionResult> sessionResults = loadSessionResults(memberUuid, sessionUuid);
        // 결과 없는 세션 UUID: LLM·토픽 집계 없이 고정 문장 (아무 UUID 로 캐시 키를 늘리지 못하게, #879)
        if (sessionResults.isEmpty()) {
            return new SessionCommentResult(joinSentences(List.of(SessionCommentPlanner.NO_SESSION_RESULT)), false);
        }
        SessionCommentPlan plan = SessionCommentPlanner.plan(
                sessionResults, statsAnalysisDataLoader.loadTopicStats(memberUuid));
        List<String> sentences = new ArrayList<>(plan.sentences());
        if (!plan.hasWrongAnswers()) {
            return new SessionCommentResult(joinSentences(sentences), true);
        }
        Optional<String> insight = requestInsight(memberUuid, sessionUuid, plan);
        insight.filter(sentence -> !sentence.isEmpty()).ifPresent(sentences::add);
        return new SessionCommentResult(joinSentences(sentences), insight.isPresent());
    }

    /** 세션 결과 1행 = { topicName, isCorrect } (제출 순) */
    private List<SessionResult> loadSessionResults(UUID memberUuid, UUID sessionUuid) {
        return submissionRepository.findTopicResultsByMemberUuidAndSessionUuid(memberUuid.toString(), sessionUuid.toString())
                .stream()
                .map(row -> new SessionResult((String) row[0], Boolean.TRUE.equals(row[1])))
                .toList();
    }

    /** 프롬프트 변수 2개 치환 > LLM > 한 문장 (실패면 empty, 버린 문장이면 빈 문자열) */
    private Optional<String> requestInsight(UUID memberUuid, UUID sessionUuid, SessionCommentPlan plan) {
        try {
            PromptTemplate prompt = promptService.getActivePrompt(PromptKey.AI_ANALYSIS_SESSION);
            List<WrongQuestionSummary> sessionWrongs = statsAnalysisQueryRepository.findSessionWrongQuestions(
                            memberUuid.toString(), sessionUuid.toString(), MAX_SESSION_WRONG_COUNT).stream()
                    // Object[] = { topicName, subtopicName(null 가능), stem }
                    .map(row -> new WrongQuestionSummary((String) row[0], (String) row[1], (String) row[2]))
                    .toList();
            String userPrompt = prompt.getUserTemplate()
                    .replace("{sessionSummary}", String.join("\n", plan.sentences()))
                    .replace("{sessionWrongs}", StatsAnalysisPromptFormatter.formatRecentWrongs(sessionWrongs));
            String rawOutput = aiChatClient.chat(prompt.getModel(), prompt.getSystemPrompt(), userPrompt,
                    prompt.getTemperature(), prompt.getMaxTokens());
            String sentence = AiAnalysisInsightParser.parseSingle(rawOutput);
            return Optional.of(sentence == null ? "" : sentence);
        } catch (Exception e) {
            log.warn("[session ai comment] insight skipped : member={}, session={}, cause={}",
                    memberUuid, sessionUuid, e.getClass().getSimpleName(), e);
            return Optional.empty();
        }
    }

    /** 문장들 > 평문 (마침표 보충, 공백 연결, 마크다운 없음) */
    static String joinSentences(List<String> sentences) {
        return sentences.stream()
                .map(StatsAnalysisService::withSentenceEnd)
                .collect(Collectors.joining(" "));
    }
}
