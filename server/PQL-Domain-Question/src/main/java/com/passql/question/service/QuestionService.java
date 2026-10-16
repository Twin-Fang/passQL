package com.passql.question.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.TextPreview;
import com.passql.meta.entity.Subtopic;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.SubtopicRepository;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.constant.QuestionActiveFilter;
import com.passql.question.dto.AdminQuestionListItem;
import com.passql.question.dto.AdminQuestionSearchCondition;
import com.passql.question.dto.ChoiceSetGenerateResponse;
import com.passql.question.dto.QuestionDetail;
import com.passql.question.dto.QuestionSummary;
import com.passql.question.dto.RecommendationsResponse;
import com.passql.question.dto.TodayQuestionResponse;
import com.passql.question.entity.DailyChallenge;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoice;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.repository.DailyChallengeRepository;
import com.passql.question.repository.QuestionChoiceRepository;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import com.passql.question.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class QuestionService {
    private final QuestionRepository questionRepository;
    private final QuestionChoiceRepository questionChoiceRepository;
    private final QuestionChoiceSetRepository choiceSetRepository;
    private final QuestionChoiceSetItemRepository choiceSetItemRepository;
    private final DailyChallengeRepository dailyChallengeRepository;
    private final TopicRepository topicRepository;
    private final SubtopicRepository subtopicRepository;
    private final ApplicationEventPublisher eventPublisher;

    public Page<QuestionSummary> getQuestions(String topicCode, String subtopic, Integer difficulty, String mode, Pageable pageable) {
        UUID topicUuid = (topicCode != null && !topicCode.isBlank())
                ? topicRepository.findByCode(topicCode).map(Topic::getTopicUuid).orElse(null)
                : null;
        ExecutionMode executionMode = (mode != null && !mode.isBlank())
                ? ExecutionMode.fromRequestValue(mode)
                : null;
        return questionRepository.findByFilters(topicUuid, difficulty, executionMode, pageable).map(this::toSummary);
    }

    /** 관리자 문제 목록: 토픽·난이도·모드·지문 검색어·활성 여부 필터 */
    public Page<AdminQuestionListItem> searchQuestionsForAdmin(AdminQuestionSearchCondition condition, Pageable pageable) {
        Specification<Question> specification = toActiveFilterSpecification(
                QuestionActiveFilter.fromRequestValueOrActive(condition.getActiveState()));
        if (StringUtils.hasText(condition.getTopic())) {
            UUID topicUuid = topicRepository.findByCode(condition.getTopic()).map(Topic::getTopicUuid).orElse(null);
            specification = specification.and((root, query, builder) -> builder.equal(root.get("topicUuid"), topicUuid));
        }
        if (condition.getDifficulty() != null) {
            specification = specification.and((root, query, builder) -> builder.equal(root.get("difficulty"), condition.getDifficulty()));
        }
        if (StringUtils.hasText(condition.getExecutionMode())) {
            ExecutionMode executionMode = ExecutionMode.fromRequestValue(condition.getExecutionMode());
            specification = specification.and((root, query, builder) -> builder.equal(root.get("executionMode"), executionMode));
        }
        if (StringUtils.hasText(condition.getKeyword())) {
            String likePattern = "%" + condition.getKeyword().trim().toLowerCase() + "%";
            specification = specification.and((root, query, builder) -> builder.like(builder.lower(root.get("stem")), likePattern));
        }
        return questionRepository.findAll(specification, pageable)
                .map(question -> AdminQuestionListItem.of(toSummary(question), question.getIsActive()));
    }

    /** 활성 여부 필터 > 조건 (ALL 은 조건 없음) */
    private Specification<Question> toActiveFilterSpecification(QuestionActiveFilter activeFilter) {
        return switch (activeFilter) {
            case ACTIVE -> (root, query, builder) -> builder.isTrue(root.get("isActive"));
            case INACTIVE -> (root, query, builder) -> builder.isFalse(root.get("isActive"));
            case ALL -> (root, query, builder) -> builder.conjunction();
        };
    }

    /** 문제 활성 여부 (관리자 상세 화면 비활성화·복구 버튼용) */
    public boolean isQuestionActive(UUID questionUuid) {
        return Boolean.TRUE.equals(getQuestionEntity(questionUuid).getIsActive());
    }

    /** 관리자 상세: 문제 전체 + 모든 선택지 세트 (정답 여부·해설·정답 SQL 포함) */
    public QuestionDetail getQuestionForAdmin(UUID questionUuid) {
        Question question = getQuestionEntity(questionUuid);
        List<QuestionDetail.ChoiceSetSummary> choiceSets = choiceSetRepository
                .findByQuestionUuidOrderByCreatedAtDesc(questionUuid)
                .stream()
                .map(choiceSet -> toChoiceSetSummary(choiceSet, true))
                .toList();
        return toQuestionDetail(question, question.getAnswerSql(), choiceSets);
    }

    /**
     * 풀이용 상세: 정답 SQL 제외, 최신 OK 세트 1개만 (정답 여부·해설 제외) (#503)
     * 정답·해설은 제출 응답에서만 내려간다.
     */
    public QuestionDetail getQuestionForSolving(UUID questionUuid) {
        Question question = getQuestionEntity(questionUuid);
        List<QuestionDetail.ChoiceSetSummary> choiceSets = choiceSetRepository
                .findFirstByQuestionUuidAndStatusOrderByCreatedAtDesc(questionUuid, ChoiceSetStatus.OK)
                .map(choiceSet -> List.of(toChoiceSetSummary(choiceSet, false)))
                .orElse(List.of());
        return toQuestionDetail(question, null, choiceSets);
    }

    /** 선택지 세트 > 요약 (shouldIncludeAnswer=false 면 정답 여부·해설 null) */
    private QuestionDetail.ChoiceSetSummary toChoiceSetSummary(QuestionChoiceSet choiceSet, boolean shouldIncludeAnswer) {
        List<QuestionDetail.ChoiceItem> items = choiceSetItemRepository
                .findByChoiceSetUuidOrderBySortOrderAsc(choiceSet.getChoiceSetUuid())
                .stream()
                .map(item -> new QuestionDetail.ChoiceItem(
                        item.getChoiceKey(), item.getKind(), item.getBody(),
                        shouldIncludeAnswer ? item.getIsCorrect() : null,
                        shouldIncludeAnswer ? item.getRationale() : null,
                        item.getSortOrder()))
                .toList();
        return new QuestionDetail.ChoiceSetSummary(
                choiceSet.getChoiceSetUuid(),
                choiceSet.getSource(),
                choiceSet.getStatus(),
                choiceSet.getSandboxValidationPassed(),
                choiceSet.getCreatedAt(),
                items);
    }

    private QuestionDetail toQuestionDetail(Question question, String answerSql,
                                            List<QuestionDetail.ChoiceSetSummary> choiceSets) {
        return new QuestionDetail(
                question.getQuestionUuid(),
                topicName(question.getTopicUuid()),
                subtopicName(question.getSubtopicUuid()),
                question.getDifficulty(),
                question.getExecutionMode(),
                question.getChoiceSetPolicy(),
                question.getStem(),
                question.getSchemaDisplay(),
                question.getSchemaDdl(),
                question.getSchemaSampleData(),
                question.getSchemaIntent(),
                answerSql,
                question.getHint(),
                choiceSets
        );
    }

    /** 풀이용 선택지 세트 > 응답 (정답 여부·해설 제외) */
    public ChoiceSetGenerateResponse getChoiceSetForSolving(UUID choiceSetUuid) {
        List<ChoiceSetGenerateResponse.ChoiceItem> choiceItems = choiceSetItemRepository
                .findByChoiceSetUuidOrderBySortOrderAsc(choiceSetUuid)
                .stream()
                .map(item -> new ChoiceSetGenerateResponse.ChoiceItem(
                        item.getChoiceKey(),
                        item.getKind().name(),
                        item.getBody(),
                        item.getSortOrder()))
                .toList();
        return new ChoiceSetGenerateResponse(choiceSetUuid, choiceItems);
    }

    public Question getQuestionEntity(UUID questionUuid) {
        return questionRepository.findById(questionUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.QUESTION_NOT_FOUND));
    }

    /** 존재하지 않는 UUID면 null 반환 — HomeService의 데일리 세트 조회 시 소프트 폴백용 */
    public Question getQuestionEntityOrNull(UUID questionUuid) {
        return questionRepository.findById(questionUuid).orElse(null);
    }

    /**
     * Resolve today's question (from DailyChallenge or deterministic fallback).
     * 폴백으로 선택된 경우 daily_challenge 테이블에 즉시 저장한다 (스케줄러 실패 백업).
     * REQUIRES_NEW: 호출자가 readOnly 트랜잭션을 열고 있어도 독립적인 쓰기 트랜잭션으로 처리한다.
     * Returns null if no active questions exist.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public Question resolveTodayQuestion() {
        // 데일리 세트 첫 번째 문제를 단건 챌린지 대표로 반환 (레거시 호환)
        List<DailyChallenge> challenges = dailyChallengeRepository.findByChallengeDateOrderBySortOrderAsc(LocalDate.now());
        if (!challenges.isEmpty()) {
            return questionRepository.findById(challenges.get(0).getQuestionUuid()).orElse(null);
        }
        return null;
    }

    public TodayQuestionResponse getTodayResponse(boolean alreadySolved) {
        Question question = resolveTodayQuestion();
        if (question == null) {
            return new TodayQuestionResponse(null, false);
        }
        return new TodayQuestionResponse(toSummary(question), alreadySolved);
    }

    /**
     * RANDOM 기반 추천.
     * memberUuid 없거나 AI 추천 실패 시 호출되는 fallback.
     */
    public RecommendationsResponse getRecommendations(int size, List<UUID> excludeQuestionUuids) {
        int clamped = Math.max(1, Math.min(size, 5));

        // 오늘 데일리 세트 문제들을 추천 제외 목록에 추가
        List<String> excludeList = new ArrayList<>(
                excludeQuestionUuids != null
                        ? excludeQuestionUuids.stream().map(UUID::toString).toList()
                        : List.of()
        );
        dailyChallengeRepository.findByChallengeDateOrderBySortOrderAsc(LocalDate.now())
                .forEach(dc -> excludeList.add(dc.getQuestionUuid().toString()));

        List<Question> list = excludeList.isEmpty()
                ? questionRepository.findRandomActive(clamped)
                : questionRepository.findRandomActiveExcludingList(clamped, excludeList);
        return new RecommendationsResponse(list.stream().map(this::toSummary).toList());
    }

    /**
     * AI 추천 결과(questionUuid 목록)를 받아 QuestionSummary 목록으로 변환.
     * Application 레이어의 RecommendationService에서 호출한다.
     */
    public RecommendationsResponse getRecommendationsByUuids(List<String> questionUuids) {
        List<Question> questions = questionUuids.stream()
                .map(uuidStr -> {
                    try {
                        return questionRepository.findById(UUID.fromString(uuidStr)).orElse(null);
                    } catch (IllegalArgumentException e) {
                        return null;
                    }
                })
                .filter(q -> q != null && Boolean.TRUE.equals(q.getIsActive()))
                .toList();
        return new RecommendationsResponse(questions.stream().map(this::toSummary).toList());
    }

    public QuestionSummary toSummary(Question q) {
        String stem = q.getStem();
        String preview = TextPreview.truncate(stem, TextPreview.QUESTION_SUMMARY_STEM_LENGTH);
        Topic topic = q.getTopicUuid() != null ? topicRepository.findById(q.getTopicUuid()).orElse(null) : null;
        return new QuestionSummary(
                q.getQuestionUuid(),
                topic != null ? topic.getCode() : null,
                topic != null ? topic.getDisplayName() : null,
                q.getDifficulty(),
                q.getExecutionMode(),
                preview,
                q.getCreatedAt()
        );
    }

    @Transactional
    public void updateQuestion(UUID questionUuid, String stem, String schemaDisplay, String schemaDdl,
                               String schemaSampleData, String schemaIntent, String answerSql, String hint,
                               Integer difficulty, ExecutionMode executionMode,
                               UUID topicUuid, UUID subtopicUuid) {
        Question q = questionRepository.findById(questionUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.QUESTION_NOT_FOUND));
        Map<String, Object> before = QuestionAuditSummary.of(q);
        q.setStem(stem);
        q.setSchemaDisplay(schemaDisplay);
        q.setSchemaDdl(schemaDdl);
        q.setSchemaSampleData(schemaSampleData);
        q.setSchemaIntent(schemaIntent);
        q.setAnswerSql(answerSql);
        q.setHint(hint);
        q.setDifficulty(difficulty);
        q.setExecutionMode(executionMode);
        q.setTopicUuid(topicUuid);
        q.setSubtopicUuid(subtopicUuid);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.QUESTION, questionUuid, AdminAuditAction.UPDATE,
                before, QuestionAuditSummary.of(q)));
    }

    @Transactional
    public void updateChoiceSetPolicy(UUID questionUuid, ChoiceSetPolicy policy) {
        Question q = questionRepository.findById(questionUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.QUESTION_NOT_FOUND));
        q.setChoiceSetPolicy(policy);
    }

    /**
     * 임베딩 색인 상태 확인을 위해 활성 문제 전체 UUID를 문자열 목록으로 반환.
     * AdminEmbeddingController에서 AiGatewayClient.getIndexStatus() 호출 전 사용한다.
     */
    public List<String> getAllActiveQuestionUuids() {
        List<String> uuids = questionRepository.findAllActiveQuestionUuids();
        log.debug("[embedding-status] 활성 문제 UUID 조회 완료: count={}", uuids.size());
        return uuids;
    }

    private String topicName(UUID topicUuid) {
        if (topicUuid == null) return null;
        return topicRepository.findById(topicUuid).map(Topic::getDisplayName).orElse(null);
    }

    private String subtopicName(UUID subtopicUuid) {
        if (subtopicUuid == null) return null;
        return subtopicRepository.findById(subtopicUuid).map(Subtopic::getDisplayName).orElse(null);
    }
}
