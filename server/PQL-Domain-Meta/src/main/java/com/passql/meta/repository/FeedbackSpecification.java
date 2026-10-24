package com.passql.meta.repository;

import com.passql.meta.constant.FeedbackStatus;
import com.passql.meta.entity.Feedback;
import org.springframework.data.jpa.domain.Specification;

import java.time.LocalDate;
import java.util.Collection;
import java.util.UUID;

/** 관리자 건의 검색 조건: 상태, 내용 키워드, 작성 회원, 제출 기간 (null·빈 값은 조건 없음) */
public final class FeedbackSpecification {

    // LIKE 이스케이프 문자 (키워드의 %, _ 를 글자 그대로 찾게)
    private static final char LIKE_ESCAPE_CHARACTER = '\\';

    private FeedbackSpecification() {
    }

    public static Specification<Feedback> statusEquals(FeedbackStatus status) {
        return (root, query, criteriaBuilder) ->
            status == null ? criteriaBuilder.conjunction() : criteriaBuilder.equal(root.get("status"), status);
    }

    /** 내용 부분 일치 (대소문자 무시, %·_ 는 글자 그대로) */
    public static Specification<Feedback> contentContains(String keyword) {
        return (root, query, criteriaBuilder) -> keyword == null || keyword.isBlank()
            ? criteriaBuilder.conjunction()
            : criteriaBuilder.like(criteriaBuilder.lower(root.get("content")),
                "%" + escapeLikePattern(keyword.trim().toLowerCase()) + "%", LIKE_ESCAPE_CHARACTER);
    }

    /** 작성 회원 후보 중 한 명 (null 이면 조건 없음, 빈 집합이면 결과 없음) */
    public static Specification<Feedback> memberIn(Collection<UUID> memberUuids) {
        return (root, query, criteriaBuilder) -> {
            if (memberUuids == null) {
                return criteriaBuilder.conjunction();
            }
            return memberUuids.isEmpty() ? criteriaBuilder.disjunction() : root.get("memberUuid").in(memberUuids);
        };
    }

    public static Specification<Feedback> createdFrom(LocalDate fromDate) {
        return (root, query, criteriaBuilder) -> fromDate == null ? criteriaBuilder.conjunction()
            : criteriaBuilder.greaterThanOrEqualTo(root.get("createdAt"), fromDate.atStartOfDay());
    }

    public static Specification<Feedback> createdTo(LocalDate toDate) {
        return (root, query, criteriaBuilder) -> toDate == null ? criteriaBuilder.conjunction()
            : criteriaBuilder.lessThan(root.get("createdAt"), toDate.plusDays(1).atStartOfDay());
    }

    // \ > \\, % > \%, _ > \_
    private static String escapeLikePattern(String keyword) {
        return keyword.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
    }
}
