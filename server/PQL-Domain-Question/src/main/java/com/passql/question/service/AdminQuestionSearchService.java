package com.passql.question.service;

import com.passql.meta.entity.Topic;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.constant.AdminQuestionSortType;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.constant.QuestionActiveFilter;
import com.passql.question.dto.AdminQuestionListItem;
import com.passql.question.dto.AdminQuestionSearchCondition;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionQualityStat;
import com.passql.question.repository.QuestionRepository;
import jakarta.persistence.criteria.Order;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * 관리자 문제 목록 검색: 필터 조건(토픽·난이도·모드·검색어·활성) + 품질 지표 필터·정렬
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminQuestionSearchService {

    private final QuestionRepository questionRepository;
    private final TopicRepository topicRepository;
    private final QuestionService questionService;

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
        specification = specification.and(toQualitySpecification(condition));
        return questionRepository.findAll(specification, pageable)
                .map(question -> AdminQuestionListItem.of(questionService.toSummary(question), question.getIsActive()));
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
