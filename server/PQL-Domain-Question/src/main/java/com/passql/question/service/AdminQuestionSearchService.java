package com.passql.question.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.constant.AdminQuestionSortType;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.constant.QuestionActiveFilter;
import com.passql.question.dto.AdminQuestionListItem;
import com.passql.question.dto.AdminQuestionSearchCondition;
import com.passql.question.dto.QuestionInternalTagFilter;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionInternalTag;
import com.passql.question.entity.QuestionQualityStat;
import com.passql.question.repository.QuestionRepository;
import jakarta.persistence.criteria.Order;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;

/**
 * 관리자 문제 목록 검색: 필터 조건(토픽·난이도·모드·검색어·활성·내부 태그) + 품질 지표 필터·정렬
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminQuestionSearchService {

    private final QuestionRepository questionRepository;
    private final TopicRepository topicRepository;
    private final QuestionService questionService;
    private final QuestionInternalTagService questionInternalTagService;

    // 내부 태그 앞부분 일치 LIKE 이스케이프 문자
    private static final char LIKE_ESCAPE_CHARACTER = '\\';

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
        specification = specification.and(toInternalTagSpecification(condition.getInternalTags()));
        specification = specification.and(toQualitySpecification(condition));
        Page<Question> questionPage = questionRepository.findAll(specification, pageable);
        Map<UUID, List<String>> internalTagsByQuestionUuid = questionInternalTagService.getTagsByQuestionUuid(
                questionPage.getContent().stream().map(Question::getQuestionUuid).toList());
        return questionPage.map(question -> AdminQuestionListItem.of(questionService.toSummary(question),
                question.getIsActive(),
                QuestionInternalTagService.toTagGroups(internalTagsByQuestionUuid.get(question.getQuestionUuid()))));
    }

    /**
     * 내부 태그 필터 > 조건: 필터마다 해당 태그 보유 문제 (모두 만족), 앞부분 일치는 LIKE (% _ \ 이스케이프)
     * 잘못된 필터 > INVALID_INPUT_VALUE (사유 포함)
     */
    private Specification<Question> toInternalTagSpecification(List<String> rawFilters) {
        List<QuestionInternalTagFilter> filters = toInternalTagFilters(rawFilters);
        if (filters.isEmpty()) {
            return (root, query, builder) -> builder.conjunction();
        }
        return (root, query, builder) -> builder.and(filters.stream().map(filter -> {
            Subquery<UUID> taggedQuestion = query.subquery(UUID.class);
            Root<QuestionInternalTag> tag = taggedQuestion.from(QuestionInternalTag.class);
            Predicate tagMatch = filter.isPrefixMatch()
                    ? builder.like(tag.get("tag"), escapeLikePattern(filter.matchValue()) + "%", LIKE_ESCAPE_CHARACTER)
                    : builder.equal(tag.get("tag"), filter.matchValue());
            taggedQuestion.select(tag.get("questionUuid"))
                    .where(builder.equal(tag.get("questionUuid"), root.get("questionUuid")), tagMatch);
            return builder.exists(taggedQuestion);
        }).toArray(Predicate[]::new));
    }

    /** 필터 문자열 목록 > 필터 (빈 항목 제외, 중복 제거) */
    private static List<QuestionInternalTagFilter> toInternalTagFilters(List<String> rawFilters) {
        if (rawFilters == null) {
            return List.of();
        }
        try {
            return rawFilters.stream()
                    .map(QuestionInternalTagRule::toFilterOrNull)
                    .filter(Objects::nonNull)
                    .distinct()
                    .toList();
        } catch (IllegalArgumentException exception) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, exception.getMessage());
        }
    }

    /** LIKE 특수 문자 이스케이프 (batch_06 의 _ 가 한 글자 와일드카드로 해석되지 않게) */
    private static String escapeLikePattern(String value) {
        return value.replace(String.valueOf(LIKE_ESCAPE_CHARACTER), "" + LIKE_ESCAPE_CHARACTER + LIKE_ESCAPE_CHARACTER)
                .replace("%", LIKE_ESCAPE_CHARACTER + "%")
                .replace("_", LIKE_ESCAPE_CHARACTER + "_");
    }

    /**
     * 품질 지표 조건: 신고 있는 문제만 필터 + 품질 정렬 (지표는 QuestionQualityStat 뷰와 문제 uuid 로 연결)
     * 정렬은 집계 컬럼이라 Pageable 이 아니라 여기서 지정 (본 조회만, 건수 조회는 제외), 동률은 최신순
     */
    private Specification<Question> toQualitySpecification(AdminQuestionSearchCondition condition) {
        AdminQuestionSortType sortType = AdminQuestionSortType.fromRequestValueOrNewest(condition.getSort());
        boolean isReportedOnly = Boolean.TRUE.equals(condition.getIsReportedOnly());
        if (!sortType.isQualitySort() && !isReportedOnly) {
            return (root, query, builder) -> builder.conjunction();
        }
        return (root, query, builder) -> {
            Root<QuestionQualityStat> stat = query.from(QuestionQualityStat.class);
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(builder.equal(stat.get("questionUuid"), root.get("questionUuid")));
            if (isReportedOnly) {
                predicates.add(builder.greaterThan(stat.get("reportCount"), 0L));
            }
            if (sortType == AdminQuestionSortType.ACCURACY_ASCENDING) {
                predicates.add(builder.greaterThan(stat.get("solveCount"), 0L));
            }
            boolean isCountQuery = Long.class.equals(query.getResultType()) || long.class.equals(query.getResultType());
            if (!isCountQuery && sortType.isQualitySort()) {
                Order primaryOrder = switch (sortType) {
                    case ACCURACY_ASCENDING -> builder.asc(stat.get("accuracyPercent"));
                    case SOLVE_COUNT_DESCENDING -> builder.desc(stat.get("solveCount"));
                    case REPORT_COUNT_DESCENDING -> builder.desc(stat.get("reportCount"));
                    case NEWEST -> builder.desc(root.get("createdAt"));
                };
                query.orderBy(primaryOrder, builder.desc(root.get("createdAt")));
            }
            return builder.and(predicates.toArray(new Predicate[0]));
        };
    }

    /** 활성 여부 필터 > 조건 (ALL 은 조건 없음) */
    private Specification<Question> toActiveFilterSpecification(QuestionActiveFilter activeFilter) {
        return switch (activeFilter) {
            case ACTIVE -> (root, query, builder) -> builder.isTrue(root.get("isActive"));
            case INACTIVE -> (root, query, builder) -> builder.isFalse(root.get("isActive"));
            case ALL -> (root, query, builder) -> builder.conjunction();
        };
    }
}
