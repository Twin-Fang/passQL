package com.passql.application.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.ai.client.AiChatClient;
import com.passql.ai.dto.AiCommentResponse;
import com.passql.application.entitlement.FeatureAccessPolicy;
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
import java.time.temporal.ChronoUnit;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
// 클래스 단위 트랜잭션 없음: Gemini 호출 동안 DB 커넥션을 잡지 않게 (#497)
public class AiCommentService {

    private static final String CACHE_KEY_PREFIX = "ai-comment:";
    /** 세션 단위 캐시 TTL — 결과 화면 확인 시간으로 충분 */
    private static final long CACHE_TTL_HOURS = 2;
    /** 통계 화면 캐시 TTL — 키에 날짜가 있어 하루 넘게 둘 필요 없음 (#699) */
    private static final long STATS_CACHE_TTL_HOURS = 24;
    /** 통계 화면 프로 갱신 단위 (최근 풀이 수 10문제마다 새 코멘트, 무료는 하루 1회, #699) */
    static final int PRO_STATS_REFRESH_SOLVED_COUNT = 10;
    /** 통계 화면 AI 코멘트 프롬프트 키 — 세션 없는 누적 통계 전용 */
    private static final String PROMPT_KEY_STATS = "ai_comment_stats";
    /** 결과 화면 AI 코멘트 프롬프트 키 — 세션 결과 + 누적 통계 통합 */
    private static final String PROMPT_KEY_SESSION = "ai_comment";
    // 프롬프트 날짜 형식 (yyyy-MM-dd)
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    /** 통계 화면 최근 활동 기간 (일) */
    private static final int RECENT_ACTIVITY_DAYS = 7;

    private final AiChatClient aiChatClient;
    private final TopicAnalysisService topicAnalysisService;
    private final SubmissionRepository submissionRepository;
    private final PromptService promptService;
    private final RedisTemplate<String, Object> redisTemplate;
    private final ObjectMapper objectMapper;
    private final FeatureAccessPolicy featureAccessPolicy;

    /**
     * AI 코멘트 반환.
     * - sessionUuid 있음(결과 화면): 'ai_comment' 프롬프트, 세션 결과 + 누적 토픽 통계
     * - sessionUuid 없음(통계 화면): 'ai_comment_stats' 프롬프트, 최근 7일 활동 + 누적 토픽 통계
     *
     * 캐시 키: ai-comment:{memberUuid}:{sessionUuid} / ai-comment:{memberUuid}:stats:{날짜}:{갱신 구간}
     */
    public AiCommentResponse getAiComment(UUID memberUuid, UUID sessionUuid) {
        // 통계 화면: 같은 날 같은 갱신 구간이면 캐시 재사용 > 풀이마다 LLM 호출하지 않게 (#567, #699)
        RecentActivity recentActivity = sessionUuid == null ? findRecentActivity(memberUuid) : null;
        String recentActivitySummary = recentActivity != null ? recentActivity.toPromptText() : null;
        String cacheKey = sessionUuid != null
                ? CACHE_KEY_PREFIX + memberUuid + ":" + sessionUuid
                : CACHE_KEY_PREFIX + memberUuid + ":stats:"
                        + toStatsRefreshBucket(recentActivity.today(), recentActivity.recentCount(), featureAccessPolicy.isPro(memberUuid));
        long cacheTtlHours = sessionUuid != null ? CACHE_TTL_HOURS : STATS_CACHE_TTL_HOURS;

        Object cached = redisTemplate.opsForValue().get(cacheKey);
        if (cached != null) {
            try {
                return objectMapper.readValue((String) cached, AiCommentResponse.class);
            } catch (JsonProcessingException e) {
                log.warn("AI comment cache deserialization failed for {}, regenerating", memberUuid, e);
            }
        }

        // 화면 유형에 따라 다른 프롬프트 키 사용
        String promptKey = sessionUuid != null ? PROMPT_KEY_SESSION : PROMPT_KEY_STATS;
        PromptTemplate prompt = promptService.getActivePrompt(promptKey);

        // 누적 토픽 통계 (공통)
        TopicAnalysisResponse analysis = topicAnalysisService.getTopicAnalysis(memberUuid);
        String topicStats;
        try {
            topicStats = objectMapper.writeValueAsString(analysis.topicStats());
        } catch (JsonProcessingException e) {
            log.error("Failed to serialize topic stats", e);
            return new AiCommentResponse("분석 데이터를 처리하는 중 오류가 발생했습니다.", LocalDateTime.now());
        }

        String userPrompt;
        if (sessionUuid != null) {
            // 결과 화면: 세션 결과 변수 치환
            String sessionStats = buildSessionStats(sessionUuid);
            userPrompt = prompt.getUserTemplate()
                    .replace("{sessionStats}", sessionStats)
                    .replace("{topicStats}", topicStats);
        } else {
            // 통계 화면: 최근 7일 활동 데이터 변수 치환
            userPrompt = prompt.getUserTemplate()
                    .replace("{topicStats}", topicStats)
                    .replace("{recentActivity}", recentActivitySummary);
        }

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
            log.error("Gemini AI comment generation failed for member={}, session={}", memberUuid, sessionUuid, e);
            throw new CustomException(ErrorCode.AI_UNAVAILABLE);
        }

        AiCommentResponse response = new AiCommentResponse(comment.trim(), LocalDateTime.now());

        // 캐시 저장 (결과 화면 2시간, 통계 화면 24시간)
        try {
            String json = objectMapper.writeValueAsString(response);
            redisTemplate.opsForValue().set(cacheKey, json, cacheTtlHours, TimeUnit.HOURS);
        } catch (JsonProcessingException e) {
            log.warn("Failed to cache AI comment for member={}, session={}", memberUuid, sessionUuid, e);
        }

        return response;
    }

    /** 최근 7일 학습 현황 조회 (풀이 수, 마지막 활동일, 오늘) */
    private RecentActivity findRecentActivity(UUID memberUuid) {
        LocalDateTime since = LocalDateTime.now().minusDays(RECENT_ACTIVITY_DAYS);
        List<Object[]> rows = submissionRepository.findRecentActivityStats(memberUuid.toString(), since);
        // native query는 단일 집계행도 List<Object[]>로 반환되므로 첫 행을 꺼냄
        Object[] row = rows.isEmpty() ? new Object[]{null, null} : rows.get(0);

        long recentCount = row[0] != null ? ((Number) row[0]).longValue() : 0L;
        // submitted_at 은 서버 로컬(KST) 저장값 (#560)
        LocalDate lastActiveDate = row[1] != null ? ((java.sql.Timestamp) row[1]).toLocalDateTime().toLocalDate() : null;
        return new RecentActivity(recentCount, lastActiveDate, LocalDate.now());
    }

    /** 최근 7일 학습 현황 */
    private record RecentActivity(long recentCount, LocalDate lastActiveDate, LocalDate today) {
        String toPromptText() {
            return toRecentActivitySummary(recentCount, lastActiveDate, today);
        }
    }

    /**
     * 통계 코멘트 갱신 구간: 날짜 + (프로 최근 풀이 수 10문제 단위 | 무료 하루 1회)
     * 예: 프로 23문제 > "2026-10-27:pro-2", 무료 > "2026-10-27:day"
     */
    static String toStatsRefreshBucket(LocalDate today, long recentCount, boolean isPro) {
        String dateText = today.format(DATE_FORMAT);
        return isPro
                ? dateText + ":pro-" + (recentCount / PRO_STATS_REFRESH_SOLVED_COUNT)
                : dateText + ":day";
    }

    /**
     * 최근 활동 > 프롬프트 텍스트 (오늘 날짜와 며칠 전인지 함께, 모델이 최근 활동일을 과거로 오해하지 않게 #567)
     * "오늘: 2026-10-21 / 최근 7일 풀이 수: 3문제 / 최근 활동일: 2026-10-21 (오늘)"
     */
    static String toRecentActivitySummary(long recentCount, LocalDate lastActiveDate, LocalDate today) {
        String lastActiveText = "없음";
        if (lastActiveDate != null) {
            long daysAgo = ChronoUnit.DAYS.between(lastActiveDate, today);
            lastActiveText = lastActiveDate.format(DATE_FORMAT) + (daysAgo <= 0 ? " (오늘)" : " (" + daysAgo + "일 전)");
        }
        return "오늘: " + today.format(DATE_FORMAT) + "\n"
                + "최근 " + RECENT_ACTIVITY_DAYS + "일 풀이 수: " + recentCount + "문제\n"
                + "최근 활동일: " + lastActiveText;
    }

    /** 세션 내 제출 목록을 "토픽명: 정답/오답" 형태 텍스트로 변환 */
    private String buildSessionStats(UUID sessionUuid) {
        List<Object[]> rows = submissionRepository.findTopicResultsBySessionUuid(sessionUuid.toString());
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
