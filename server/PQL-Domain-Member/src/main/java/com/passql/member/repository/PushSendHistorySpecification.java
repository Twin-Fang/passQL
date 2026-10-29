package com.passql.member.repository;

import com.passql.member.constant.PushAudience;
import com.passql.member.constant.PushDispatchStatus;
import com.passql.member.dto.PushHistorySearchCondition;
import com.passql.member.entity.PushSendHistory;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.util.StringUtils;

/** 발송 이력 검색 조건 > Specification (조건이 없으면 전체) */
public final class PushSendHistorySpecification {

    private PushSendHistorySpecification() {
    }

    public static Specification<PushSendHistory> from(PushHistorySearchCondition condition) {
        Specification<PushSendHistory> specification = (root, query, builder) -> builder.conjunction();
        if (StringUtils.hasText(condition.getKeyword())) {
            String likePattern = "%" + escapeLike(condition.getKeyword().trim().toLowerCase()) + "%";
            specification = specification.and((root, query, builder) -> builder.or(
                    builder.like(builder.lower(root.get("title")), likePattern, '\\'),
                    builder.like(builder.lower(root.get("body")), likePattern, '\\')));
        }
        if (StringUtils.hasText(condition.getAudience())) {
            PushAudience audience = PushAudience.fromRequestValue(condition.getAudience());
            specification = specification.and((root, query, builder) -> builder.equal(root.get("audience"), audience));
        }
        if (StringUtils.hasText(condition.getDispatchStatus())) {
            PushDispatchStatus dispatchStatus = PushDispatchStatus.fromRequestValue(condition.getDispatchStatus().trim());
            specification = specification.and((root, query, builder) -> builder.equal(root.get("dispatchStatus"), dispatchStatus));
        }
        if (condition.getFromDate() != null) {
            specification = specification.and((root, query, builder) ->
                    builder.greaterThanOrEqualTo(root.get("sentAt"), condition.getFromDate().atStartOfDay()));
        }
        if (condition.getToDate() != null) {
            specification = specification.and((root, query, builder) ->
                    builder.lessThan(root.get("sentAt"), condition.getToDate().plusDays(1).atStartOfDay()));
        }
        if (!Boolean.TRUE.equals(condition.getIsTestIncluded())) {
            specification = specification.and((root, query, builder) -> builder.isFalse(root.get("isTest")));
        }
        return specification;
    }

    /** LIKE 와일드카드(%, _, \\) 를 문자 그대로 검색 */
    private static String escapeLike(String keyword) {
        return keyword.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
    }
}
