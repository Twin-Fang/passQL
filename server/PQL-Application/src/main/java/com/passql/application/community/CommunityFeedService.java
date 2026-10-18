package com.passql.application.community;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.application.community.feed.FeedCandidate;
import com.passql.application.community.feed.FeedStrategy;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.MarkdownTextStripper;
import com.passql.common.util.TextPreview;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.constant.CommunityFeedSource;
import com.passql.question.dto.community.CommunityFeedCardResponse;
import com.passql.question.dto.community.CommunityFeedPageResponse;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionDiscussionStats;
import com.passql.question.repository.QuestionDiscussionStatsRepository;
import com.passql.question.repository.QuestionRepository;
import com.passql.submission.repository.SubmissionRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.EnumMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 커뮤니티 피드: 탭(source) > 전략의 후보 문제 > 오프셋 커서 페이지 > 문제 카드
 * 회원 무관 전략(hot, trend)은 후보를 Redis 60초 캐시 (community:feed:{SOURCE}), 카드는 매번 회원별로 조립
 */
@Slf4j
@Service
@Transactional(readOnly = true)
public class CommunityFeedService {

    private static final int PAGE_SIZE = 20;
    // 카드 지문 미리보기 길이 (문자 수)
    private static final int STEM_PREVIEW_LENGTH = 80;
    private static final Duration FEED_CACHE_TTL = Duration.ofSeconds(60);
    private static final TypeReference<List<FeedCandidate>> CANDIDATE_LIST_TYPE = new TypeReference<>() { };

    private final Map<CommunityFeedSource, FeedStrategy> strategyBySource = new EnumMap<>(CommunityFeedSource.class);
    private final StringRedisTemplate stringRedisTemplate;
    private final ObjectMapper objectMapper;
    private final QuestionRepository questionRepository;
    private final TopicRepository topicRepository;
    private final SubmissionRepository submissionRepository;
    private final QuestionDiscussionStatsRepository questionDiscussionStatsRepository;

    public CommunityFeedService(List<FeedStrategy> strategies, StringRedisTemplate stringRedisTemplate, ObjectMapper objectMapper,
                                QuestionRepository questionRepository, TopicRepository topicRepository,
                                SubmissionRepository submissionRepository,
                                QuestionDiscussionStatsRepository questionDiscussionStatsRepository) {
        strategies.forEach(strategy -> strategyBySource.put(strategy.source(), strategy));
        this.stringRedisTemplate = stringRedisTemplate;
        this.objectMapper = objectMapper;
        this.questionRepository = questionRepository;
        this.topicRepository = topicRepository;
        this.submissionRepository = submissionRepository;
        this.questionDiscussionStatsRepository = questionDiscussionStatsRepository;
    }

    /** 피드 한 페이지: 후보 조회(캐시) > 오프셋 자르기 > 카드 조립 */
    public CommunityFeedPageResponse getFeed(UUID viewerMemberUuid, String sourceRequestValue, String cursor) {
        CommunityFeedSource source = CommunityFeedSource.fromRequestValue(sourceRequestValue);
        int offset = decodeOffset(cursor);
        List<FeedCandidate> candidates = findCandidates(strategyBySource.get(source), viewerMemberUuid);

        int endIndex = Math.min(offset + PAGE_SIZE, candidates.size());
        List<FeedCandidate> pageCandidates = offset >= candidates.size() ? List.of() : candidates.subList(offset, endIndex);
        String nextCursor = endIndex < candidates.size() ? encodeOffset(endIndex) : null;
        return new CommunityFeedPageResponse(toCards(pageCandidates, viewerMemberUuid), nextCursor);
    }

    /** 후보 조회: 회원 무관 전략은 Redis 60초 캐시 (장애 시 직접 조회) */
    private List<FeedCandidate> findCandidates(FeedStrategy strategy, UUID viewerMemberUuid) {
        LocalDateTime now = LocalDateTime.now();
        if (!strategy.isSharedAcrossMembers()) {
            return strategy.findCandidates(viewerMemberUuid, now);
        }
        String cacheKey = "community:feed:" + strategy.source();
        try {
            String cached = stringRedisTemplate.opsForValue().get(cacheKey);
            if (cached != null) {
                return objectMapper.readValue(cached, CANDIDATE_LIST_TYPE);
            }
            List<FeedCandidate> fresh = strategy.findCandidates(viewerMemberUuid, now);
            stringRedisTemplate.opsForValue().set(cacheKey, objectMapper.writeValueAsString(fresh), FEED_CACHE_TTL);
            return fresh;
        } catch (DataAccessException | JsonProcessingException e) {
            log.warn("[community] feed cache skipped : source={}, cause={}", strategy.source(), e.getClass().getSimpleName());
            return strategy.findCandidates(viewerMemberUuid, now);
        }
    }

    /** 후보 > 카드: 문제·토픽·집계·풀이 여부를 한 번에 조회 (비활성 문제는 제외) */
    private List<CommunityFeedCardResponse> toCards(List<FeedCandidate> candidates, UUID viewerMemberUuid) {
        if (candidates.isEmpty()) {
            return List.of();
        }
        List<UUID> questionUuids = candidates.stream().map(FeedCandidate::questionUuid).toList();
        Map<UUID, Question> questionByUuid = questionRepository.findAllById(questionUuids).stream()
                .filter(Question::getIsActive).collect(Collectors.toMap(Question::getQuestionUuid, Function.identity()));
        Map<UUID, Topic> topicByUuid = topicRepository.findAllById(
                questionByUuid.values().stream().map(Question::getTopicUuid).collect(Collectors.toSet())).stream()
                .collect(Collectors.toMap(Topic::getTopicUuid, Function.identity()));
        Map<UUID, QuestionDiscussionStats> statsByQuestionUuid = questionDiscussionStatsRepository
                .findWithPostsByQuestionUuidIn(questionUuids).stream()
                .collect(Collectors.toMap(QuestionDiscussionStats::getQuestionUuid, Function.identity()));
        Set<UUID> solvedQuestionUuids = new HashSet<>(submissionRepository.findSolvedQuestionUuids(viewerMemberUuid, questionUuids));

        return candidates.stream().filter(candidate -> questionByUuid.containsKey(candidate.questionUuid())).map(candidate -> {
            Question question = questionByUuid.get(candidate.questionUuid());
            Topic topic = topicByUuid.get(question.getTopicUuid());
            QuestionDiscussionStats stats = statsByQuestionUuid.get(candidate.questionUuid());
            return new CommunityFeedCardResponse(
                    candidate.questionUuid(),
                    TextPreview.truncate(MarkdownTextStripper.toPlainText(question.getStem()), STEM_PREVIEW_LENGTH),
                    topic == null ? null : topic.getCode(),
                    topic == null ? null : topic.getDisplayName(),
                    stats == null ? candidate.postCount() : stats.getPostCount(),
                    stats == null ? candidate.lastActivityAt() : stats.getLastActivityAt(),
                    solvedQuestionUuids.contains(candidate.questionUuid()),
                    candidate.myPostCount(),
                    candidate.receivedLikeCount());
        }).toList();
    }

    private static String encodeOffset(int offset) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(String.valueOf(offset).getBytes(StandardCharsets.UTF_8));
    }

    private static int decodeOffset(String cursor) {
        if (cursor == null || cursor.isBlank()) {
            return 0;
        }
        try {
            int offset = Integer.parseInt(new String(Base64.getUrlDecoder().decode(cursor), StandardCharsets.UTF_8));
            if (offset < 0) {
                throw new NumberFormatException("negative offset");
            }
            return offset;
        } catch (IllegalArgumentException e) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "cursor");
        }
    }
}
