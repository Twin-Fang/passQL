package com.passql.question.service;

import com.passql.common.util.UuidUtils;
import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.MarkdownTextStripper;
import com.passql.common.util.TextPreview;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.dto.QuestionFormatInput;
import com.passql.question.dto.QuestionSummary;
import com.passql.question.dto.RecommendationsResponse;
import com.passql.question.dto.TodayQuestionResponse;
import com.passql.question.entity.DailyChallenge;
import com.passql.question.entity.Question;
import com.passql.question.repository.DailyChallengeRepository;
import com.passql.question.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 문제 조회·목록·추천·수정 (상세 조립 QuestionDetailService, 관리자 검색 AdminQuestionSearchService, 세트 조회 QuestionChoiceSetQueryService)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class QuestionService {
    // 회원 문제 목록 한 페이지 최대 크기 (개, 앱·웹은 10 사용, 큰 size 로 목록 통째 수집 방지 #860)
    static final int MAX_QUESTION_LIST_PAGE_SIZE = 50;

    private final QuestionRepository questionRepository;
    private final DailyChallengeRepository dailyChallengeRepository;
    private final TopicRepository topicRepository;
    private final ApplicationEventPublisher eventPublisher;

    /** 문제 목록: 토픽·난이도·모드·최신 경향 필터 (isLatestTrend null 이면 전체), 페이지 크기 최대 50 */
    public Page<QuestionSummary> getQuestions(String topicCode, String subtopic, Integer difficulty, String mode,
                                              Boolean isLatestTrend, Pageable pageable) {
        UUID topicUuid = (topicCode != null && !topicCode.isBlank())
                ? topicRepository.findByCode(topicCode).map(Topic::getTopicUuid).orElse(null)
                : null;
        ExecutionMode executionMode = (mode != null && !mode.isBlank())
                ? ExecutionMode.fromRequestValue(mode)
                : null;
        Pageable cappedPageable = pageable.getPageSize() > MAX_QUESTION_LIST_PAGE_SIZE
                ? PageRequest.of(pageable.getPageNumber(), MAX_QUESTION_LIST_PAGE_SIZE, pageable.getSort())
                : pageable;
        return questionRepository.findByFilters(topicUuid, difficulty, executionMode, isLatestTrend, cappedPageable).map(this::toSummary);
    }

    /** 문제 활성 여부 (관리자 상세 화면 비활성화·복구 버튼용) */
    public boolean isQuestionActive(UUID questionUuid) {
        return Boolean.TRUE.equals(getQuestionEntity(questionUuid).getIsActive());
    }

    public Question getQuestionEntity(UUID questionUuid) {
        return questionRepository.findById(questionUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.QUESTION_NOT_FOUND));
    }

    /** 풀이용 문제 조회: 없거나 비활성이면 404 QUESTION_NOT_FOUND (비활성 문제는 열기·보기 생성 거부, #879) */
    public Question getActiveQuestionEntity(UUID questionUuid) {
        return questionRepository.findById(questionUuid)
                .filter(question -> Boolean.TRUE.equals(question.getIsActive()))
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

    /** 풀 수 있는 활성 문제 uuid 전체 (랜덤 풀기 후보) */
    public List<UUID> findPlayableActiveQuestionUuids() {
        return questionRepository.findPlayableActiveQuestionUuids().stream().map(UUID::fromString).toList();
    }

    /** 선택지 생성 대기 없이 바로 열 수 있는 활성 문제 uuid (잠금화면 출제 후보, isExecutableExcluded 면 실행형 제외) */
    public List<UUID> findReadyActiveQuestionUuids(boolean isExecutableExcluded) {
        return questionRepository.findReadyActiveQuestionUuids(isExecutableExcluded, ChoiceSetSource.CURATED_SOURCES);
    }

    /**
     * AI 추천 결과(questionUuid 목록)를 받아 QuestionSummary 목록으로 변환.
     * Application 레이어의 RecommendationService에서 호출한다.
     */
    public RecommendationsResponse getRecommendationsByUuids(List<String> questionUuids) {
        List<Question> questions = questionUuids.stream()
                .map(uuidText -> UuidUtils.parseOrEmpty(uuidText).flatMap(questionRepository::findById).orElse(null))
                .filter(q -> q != null && Boolean.TRUE.equals(q.getIsActive()))
                .toList();
        return new RecommendationsResponse(questions.stream().map(this::toSummary).toList());
    }

    public QuestionSummary toSummary(Question q) {
        String stem = q.getStem();
        String preview = TextPreview.truncate(MarkdownTextStripper.replaceTables(stem), TextPreview.QUESTION_SUMMARY_STEM_LENGTH);
        Topic topic = q.getTopicUuid() != null ? topicRepository.findById(q.getTopicUuid()).orElse(null) : null;
        return new QuestionSummary(
                q.getQuestionUuid(),
                topic != null ? topic.getCode() : null,
                topic != null ? topic.getDisplayName() : null,
                q.getDifficulty(),
                q.getExecutionMode(),
                preview,
                q.getCreatedAt(),
                Boolean.TRUE.equals(q.getIsLatestTrend())
        );
    }

    @Transactional
    public void updateQuestion(UUID questionUuid, String stem, String schemaDisplay, String schemaDdl,
                               String schemaSampleData, String schemaIntent, String answerSql, String hint,
                               Integer difficulty, ExecutionMode executionMode,
                               UUID topicUuid, UUID subtopicUuid) {
        Question q = questionRepository.findById(questionUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.QUESTION_NOT_FOUND));
        // 문항 형식 규칙 (#905): 저장본에 없던 위반 사유가 새로 생기면 거부
        QuestionFormatGate.requireNoNewReasons(
                QuestionFormatInput.withoutChoices(q.getStem(), q.getHint(), q.getSchemaDdl(), q.getSchemaSampleData(),
                        q.getExecutionMode()),
                QuestionFormatInput.withoutChoices(stem, hint, schemaDdl, schemaSampleData, executionMode));
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

}
