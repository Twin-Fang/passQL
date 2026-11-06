package com.passql.application.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.ai.client.AiChatClient;
import com.passql.ai.dto.AiCommentResponse;
import com.passql.application.service.statsanalysis.StatsAnalysisService;
import com.passql.application.service.statsanalysis.StatsAnalysisService.StatsAnalysisResult;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.service.PromptService;
import com.passql.submission.repository.SubmissionRepository;
import com.passql.submission.service.TopicAnalysisService;
import com.passql.submission.dto.TopicAnalysisResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
// 클래스 단위 트랜잭션 없음: LLM 호출 동안 DB 커넥션을 잡지 않게 (#497)
public class AiCommentService {

    private static final String CACHE_KEY_PREFIX = "ai-comment:";
    /** 세션 단위 캐시 TTL — 결과 화면 확인 시간으로 충분 */
    private static final long CACHE_TTL_HOURS = 2;
    /** 통계 화면 캐시 TTL — 키에 날짜가 있어 하루 넘게 둘 필요 없음 (#699) */
    private static final long STATS_CACHE_TTL_HOURS = 24;
    /** 통계 화면 갱신 단위 (최근 풀이 수 10문제마다 새 코멘트, #699) */
    static final int STATS_REFRESH_SOLVED_COUNT = 10;
    /** 결과 화면 AI 코멘트 프롬프트 키 — 세션 결과 + 누적 통계 통합 */
    private static final String PROMPT_KEY_SESSION = "ai_comment";
    // 캐시 키 날짜 형식 (yyyy-MM-dd)
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    /** 통계 화면 최근 활동 기간 (일) */
    private static final int RECENT_ACTIVITY_DAYS = 7;

    private final AiChatClient aiChatClient;
    private final TopicAnalysisService topicAnalysisService;
    private final SubmissionRepository submissionRepository;
    private final PromptService promptService;
    private final StatsAnalysisService statsAnalysisService;
    private final RedisTemplate<String, Object> redisTemplate;
    private final ObjectMapper objectMapper;

    /**
     * AI 코멘트 반환.
     * - sessionUuid 있음(결과 화면): 'ai_comment' 프롬프트, 세션 결과 + 누적 토픽 통계 (analysis 없음)
     * - sessionUuid 없음(통계 화면): 서버 판정 구조화 분석 + 토픽별 한 문장 (StatsAnalysisService, #861)
     *
     * 캐시 키: ai-comment:{memberUuid}:{sessionUuid} / ai-comment:{memberUuid}:stats:{날짜}:{갱신 구간}
     * 등급 잠금은 컨트롤러 @RequiresProFeature(AI_COMMENT) 에서 (두 형태 모두 프로 전용, #860)
     */
    public AiCommentResponse getAiComment(UUID memberUuid, UUID sessionUuid) {
        // 통계 화면: 같은 날 같은 갱신 구간이면 캐시 재사용 > 풀이마다 LLM 호출하지 않게 (#567, #699)
        String cacheKey = sessionUuid != null
                ? CACHE_KEY_PREFIX + memberUuid + ":" + sessionUuid
                : CACHE_KEY_PREFIX + memberUuid + ":stats:" + toStatsRefreshBucket(LocalDate.now(), countRecentSubmissions(memberUuid));
        long cacheTtlHours = sessionUuid != null ? CACHE_TTL_HOURS : STATS_CACHE_TTL_HOURS;

        AiCommentResponse cached = readCache(cacheKey, memberUuid);
        if (cached != null) {
            return cached;
        }

        // 통계 화면: 분석 실패(LLM·해석)면 insight 없이 응답하고 캐시하지 않음 > 다음 진입에 다시 시도
        if (sessionUuid == null) {
            StatsAnalysisResult statsResult = statsAnalysisService.analyze(memberUuid);
            if (statsResult.isCacheable()) {
                writeCache(cacheKey, statsResult.response(), cacheTtlHours, memberUuid, null);
            }
            return statsResult.response();
        }

        AiCommentResponse response = generateSessionComment(memberUuid, sessionUuid);
        writeCache(cacheKey, response, cacheTtlHours, memberUuid, sessionUuid);
        return response;
    }

    /** 결과 화면 코멘트: 세션 결과 + 누적 토픽 통계 > 'ai_comment' 프롬프트 > LLM */
    private AiCommentResponse generateSessionComment(UUID memberUuid, UUID sessionUuid) {
        PromptTemplate prompt = promptService.getActivePrompt(PROMPT_KEY_SESSION);

        TopicAnalysisResponse analysis = topicAnalysisService.getTopicAnalysis(memberUuid);
        String topicStats;
        try {
            topicStats = objectMapper.writeValueAsString(analysis.topicStats());
        } catch (JsonProcessingException e) {
            log.error("Failed to serialize topic stats", e);
            return new AiCommentResponse("분석 데이터를 처리하는 중 오류가 발생했습니다.", LocalDateTime.now());
        }
        String userPrompt = prompt.getUserTemplate()
                .replace("{sessionStats}", buildSessionStats(memberUuid, sessionUuid))
                .replace("{topicStats}", topicStats);

        // LLM 호출 (모델 이름으로 Gemini·Claude 선택)
        String comment;
        try {
            comment = aiChatClient.chat(
                    prompt.getModel(),
                    prompt.getSystemPrompt(),
                    userPrompt,
                    prompt.getTemperature(),
                    prompt.getMaxTokens()
            );
        } catch (Exception e) {
            log.error("[ai comment] session comment generation failed : member={}, session={}", memberUuid, sessionUuid, e);
            throw new CustomException(ErrorCode.AI_UNAVAILABLE);
        }
        return new AiCommentResponse(comment.trim(), LocalDateTime.now());
    }

    private AiCommentResponse readCache(String cacheKey, UUID memberUuid) {
        Object cached = redisTemplate.opsForValue().get(cacheKey);
        if (cached == null) {
            return null;
        }
        try {
            return objectMapper.readValue((String) cached, AiCommentResponse.class);
        } catch (JsonProcessingException e) {
            log.warn("AI comment cache deserialization failed for {}, regenerating", memberUuid, e);
            return null;
        }
    }

    /** 캐시 저장 (결과 화면 2시간, 통계 화면 24시간) */
    private void writeCache(String cacheKey, AiCommentResponse response, long cacheTtlHours, UUID memberUuid, UUID sessionUuid) {
        try {
            String json = objectMapper.writeValueAsString(response);
            redisTemplate.opsForValue().set(cacheKey, json, cacheTtlHours, TimeUnit.HOURS);
        } catch (JsonProcessingException e) {
            log.warn("Failed to cache AI comment for member={}, session={}", memberUuid, sessionUuid, e);
        }
    }

    /** 최근 7일 제출 수 (통계 캐시 갱신 구간 계산) */
    private long countRecentSubmissions(UUID memberUuid) {
        LocalDateTime since = LocalDateTime.now().minusDays(RECENT_ACTIVITY_DAYS);
        List<Object[]> rows = submissionRepository.findRecentActivityStats(memberUuid.toString(), since);
        // native query는 단일 집계행도 List<Object[]>로 반환되므로 첫 행을 꺼냄
        return rows.isEmpty() || rows.get(0)[0] == null ? 0L : ((Number) rows.get(0)[0]).longValue();
    }

    /**
     * 통계 코멘트 갱신 구간: 날짜 + 최근 풀이 수 10문제 단위
     * 예: 23문제 > "2026-10-27:analysis-2" (구조화 분석 이전 캐시 "pro-" 와 겹치지 않게, #861)
     */
    static String toStatsRefreshBucket(LocalDate today, long recentCount) {
        return today.format(DATE_FORMAT) + ":analysis-" + (recentCount / STATS_REFRESH_SOLVED_COUNT);
    }

    /** 본인 세션 제출 목록 > "토픽명: 정답/오답" 텍스트 (남의 세션 UUID 면 빈 결과, #860) */
    private String buildSessionStats(UUID memberUuid, UUID sessionUuid) {
        List<Object[]> rows = submissionRepository.findTopicResultsByMemberUuidAndSessionUuid(
                memberUuid.toString(), sessionUuid.toString());
        if (rows.isEmpty()) {
            return "세션 데이터 없음";
        }
        return rows.stream()
                .map(row -> {
                    String topicName = (String) row[0];
                    Boolean isCorrect = (Boolean) row[1];
                    return topicName + ": " + (Boolean.TRUE.equals(isCorrect) ? "정답" : "오답");
                })
                .collect(Collectors.joining("\n"));
    }

    /**
     * AI 코멘트 캐시 무효화.
     * - sessionUuid 있음: 결과 화면 캐시(ai-comment:{memberUuid}:{sessionUuid}) 삭제
     * - sessionUuid 없음: 통계 화면 캐시(ai-comment:{memberUuid}:stats) 삭제
     */
    @Transactional
    public void evictCache(UUID memberUuid, UUID sessionUuid) {
        String cacheKey = sessionUuid != null
                ? CACHE_KEY_PREFIX + memberUuid + ":" + sessionUuid
                : CACHE_KEY_PREFIX + memberUuid + ":stats";
        redisTemplate.delete(cacheKey);
    }
}
