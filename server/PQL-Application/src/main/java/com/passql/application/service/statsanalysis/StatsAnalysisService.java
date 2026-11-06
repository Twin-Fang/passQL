package com.passql.application.service.statsanalysis;

import com.passql.ai.client.AiChatClient;
import com.passql.ai.dto.AiAnalysisFinding;
import com.passql.ai.dto.AiCommentResponse;
import com.passql.ai.dto.AiStatsAnalysis;
import com.passql.meta.constant.PromptKey;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.service.PromptService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * 통계 화면 AI 분석 (#861, #862): 데이터 조회 > 서버 판정 > 집중 토픽 있으면 LLM 한 문장 > 구버전 앱용 평문
 * LLM·해석 실패(프롬프트 없음 포함)는 insight 없이 분석 그대로 응답 (5xx 없음)
 */
@Slf4j
@Service
@RequiredArgsConstructor
// 클래스 단위 트랜잭션 없음: LLM 호출 동안 DB 커넥션을 잡지 않게 (#497)
public class StatsAnalysisService {

    // 문장 끝 부호 (평문 이어 붙일 때 마침표 보충 판정)
    private static final Pattern SENTENCE_END_PATTERN = Pattern.compile(".*[.!?]$");

    private final StatsAnalysisDataLoader statsAnalysisDataLoader;
    private final PromptService promptService;
    private final AiChatClient aiChatClient;

    /** 분석 결과 + 캐시 여부 (LLM 실패로 insight 가 빠졌으면 캐시하지 않고 다음 진입에 다시 시도) */
    public record StatsAnalysisResult(AiCommentResponse response, boolean isCacheable) {}

    /** 통계 AI 분석: 판정 > (집중 토픽 있으면) LLM 한 문장 > 응답 */
    public StatsAnalysisResult analyze(UUID memberUuid) {
        StatsAnalysisPlan plan = AiAnalysisPlanner.plan(statsAnalysisDataLoader.loadInput(memberUuid));
        if (!plan.hasFocusTopics()) {
            return new StatsAnalysisResult(toResponse(plan.analysis()), true);
        }
        Optional<Map<UUID, String>> insightByTopicUuid = requestInsights(memberUuid, plan.focusTopics());
        AiStatsAnalysis analysis = insightByTopicUuid
                .map(insights -> withInsights(plan.analysis(), insights))
                .orElse(plan.analysis());
        return new StatsAnalysisResult(toResponse(analysis), insightByTopicUuid.isPresent());
    }

    /** 프롬프트 변수 3개 치환 > LLM > 토픽별 한 문장 (실패면 empty) */
    private Optional<Map<UUID, String>> requestInsights(UUID memberUuid, List<TopicLearningStat> focusTopics) {
        try {
            PromptTemplate prompt = promptService.getActivePrompt(PromptKey.AI_ANALYSIS_STATS);
            String userPrompt = prompt.getUserTemplate()
                    .replace("{focusTopics}", StatsAnalysisPromptFormatter.formatFocusTopics(focusTopics))
                    .replace("{subtopicStats}", StatsAnalysisPromptFormatter.formatSubtopicStats(
                            statsAnalysisDataLoader.loadSubtopicStats(memberUuid, focusTopics)))
                    .replace("{recentWrongs}", StatsAnalysisPromptFormatter.formatRecentWrongs(
                            statsAnalysisDataLoader.loadRecentWrongs(memberUuid, focusTopics)));
            String rawOutput = aiChatClient.chat(prompt.getModel(), prompt.getSystemPrompt(), userPrompt,
                    prompt.getTemperature(), prompt.getMaxTokens());
            Set<UUID> focusTopicUuids = focusTopics.stream().map(TopicLearningStat::topicUuid).collect(Collectors.toSet());
            return Optional.of(AiAnalysisInsightParser.parse(rawOutput, focusTopicUuids));
        } catch (Exception e) {
            log.warn("[stats ai analysis] insights skipped : member={}, cause={}", memberUuid, e.getClass().getSimpleName(), e);
            return Optional.empty();
        }
    }

    private static AiStatsAnalysis withInsights(AiStatsAnalysis analysis, Map<UUID, String> insightByTopicUuid) {
        List<AiAnalysisFinding> findings = analysis.findings().stream()
                .map(finding -> finding.withInsight(insightByTopicUuid.get(finding.topicUuid())))
                .toList();
        return analysis.withFindings(findings);
    }

    private static AiCommentResponse toResponse(AiStatsAnalysis analysis) {
        return new AiCommentResponse(toPlainComment(analysis), LocalDateTime.now(), analysis);
    }

    /**
     * 구버전 앱용 평문: 한 줄 요약 + 예상 점수 + 토픽별 한 문장(없으면 "토픽: 근거") + 데이터 부족·다음 목표 공백 연결, 마크다운 없음
     * 예: "D-7 · 1과목 정답률 50%, 과락 위험이 커요. 예상 58점 (1과목 예상 5/10 · 2과목 예상 24/40), 합격선 근처. 데이터 모델링: 6문제 중 3문제 정답 (50%)."
     */
    static String toPlainComment(AiStatsAnalysis analysis) {
        Stream<String> forecastSentence = Stream.ofNullable(analysis.forecast())
                .map(forecast -> "예상 " + forecast.expectedScore() + "점 (" + forecast.summary() + "), " + forecast.verdictLabel());
        Stream<String> findingSentences = analysis.findings().stream()
                .map(finding -> finding.insight() != null
                        ? finding.insight()
                        : finding.topicName() + ": " + finding.evidence());
        Stream<String> guideSentences = Stream.concat(
                Stream.ofNullable(analysis.readiness()).map(readiness -> readiness.message()),
                Stream.ofNullable(analysis.nextGoal()));
        return Stream.of(Stream.of(analysis.headline()), forecastSentence, findingSentences, guideSentences)
                .flatMap(sentences -> sentences)
                .map(StatsAnalysisService::withSentenceEnd)
                .collect(Collectors.joining(" "));
    }

    /** 문장 끝 부호 없으면 마침표 보충 (평문 이어 붙이기, 세션 코멘트 공용) */
    static String withSentenceEnd(String sentence) {
        return SENTENCE_END_PATTERN.matcher(sentence).matches() ? sentence : sentence + ".";
    }
}
