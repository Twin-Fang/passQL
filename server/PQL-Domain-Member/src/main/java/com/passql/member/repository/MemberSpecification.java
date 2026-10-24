package com.passql.member.repository;

import com.passql.member.constant.MemberPlan;
import com.passql.member.constant.MemberPlanFilter;
import com.passql.member.constant.MemberRole;
import com.passql.member.constant.MemberStatus;
import com.passql.member.entity.Member;
import com.passql.member.entity.MemberEntitlement;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;
import org.springframework.data.jpa.domain.Specification;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

public class MemberSpecification {

    // 프로 만료 임박 기준 (일)
    public static final int PRO_EXPIRING_WITHIN_DAYS = 7;

    /** 마지막 접속 정렬: 미접속(null) 위치 지정 > 접속 시각 > 가입 최신순 (건수 조회에는 적용 안 함) */
    public static Specification<Member> orderByLastSeen(boolean isNeverSeenFirst, boolean isNewestFirst) {
        return (root, query, cb) -> {
            boolean isCountQuery = Long.class.equals(query.getResultType()) || long.class.equals(query.getResultType());
            if (!isCountQuery) {
                // 미접속 순위: 0 이 먼저 나옴
                var neverSeenRank = cb.<Integer>selectCase()
                    .when(cb.isNull(root.get("lastSeenAt")), isNeverSeenFirst ? 0 : 1)
                    .otherwise(isNeverSeenFirst ? 1 : 0);
                query.orderBy(
                    cb.asc(neverSeenRank),
                    isNewestFirst ? cb.desc(root.get("lastSeenAt")) : cb.asc(root.get("lastSeenAt")),
                    cb.desc(root.get("createdAt")));
            }
            return cb.conjunction();
        };
    }

    public static Specification<Member> notDeleted() {
        return (root, query, cb) -> cb.equal(root.get("isDeleted"), false);
    }

    public static Specification<Member> nicknameContains(String nickname) {
        return (root, query, cb) ->
            nickname == null || nickname.isBlank()
                ? cb.conjunction()
                : cb.like(cb.lower(root.get("nickname")), "%" + nickname.toLowerCase() + "%");
    }

    public static Specification<Member> statusEquals(MemberStatus status) {
        return (root, query, cb) ->
            status == null ? cb.conjunction() : cb.equal(root.get("status"), status);
    }

    public static Specification<Member> roleEquals(MemberRole role) {
        return (root, query, cb) ->
            role == null ? cb.conjunction() : cb.equal(root.get("role"), role);
    }

    public static Specification<Member> joinedAfter(LocalDate from) {
        return (root, query, cb) ->
            from == null ? cb.conjunction()
                : cb.greaterThanOrEqualTo(root.get("createdAt"), from.atStartOfDay());
    }

    public static Specification<Member> joinedBefore(LocalDate to) {
        return (root, query, cb) ->
            to == null ? cb.conjunction()
                : cb.lessThan(root.get("createdAt"), to.plusDays(1).atStartOfDay());
    }

    public static Specification<Member> lastSeenAfter(LocalDate from) {
        return (root, query, cb) ->
            from == null ? cb.conjunction()
                : cb.greaterThanOrEqualTo(root.get("lastSeenAt"), from.atStartOfDay());
    }

    public static Specification<Member> lastSeenBefore(LocalDate to) {
        return (root, query, cb) ->
            to == null ? cb.conjunction()
                : cb.lessThan(root.get("lastSeenAt"), to.plusDays(1).atStartOfDay());
    }

    /** 회원 UUID 정확히 일치 (비면 조건 없음, 형식이 틀리면 결과 없음) */
    public static Specification<Member> memberUuidEquals(String memberUuidText) {
        return (root, query, cb) -> {
            if (memberUuidText == null || memberUuidText.isBlank()) {
                return cb.conjunction();
            }
            try {
                return cb.equal(root.get("memberUuid"), UUID.fromString(memberUuidText.trim()));
            } catch (IllegalArgumentException invalidUuidFormat) {
                return cb.disjunction();
            }
        };
    }

    /** 이용권 필터: 프로 이용 중(만료 전), 만료 임박(7일 이내 만료) */
    public static Specification<Member> planMatches(MemberPlanFilter planFilter, LocalDateTime now) {
        return (root, query, cb) -> {
            if (planFilter == null) {
                return cb.conjunction();
            }
            Subquery<UUID> entitlementSubquery = query.subquery(UUID.class);
            Root<MemberEntitlement> entitlement = entitlementSubquery.from(MemberEntitlement.class);
            Predicate isProActive = cb.and(
                cb.equal(entitlement.get("plan"), MemberPlan.PRO),
                cb.greaterThan(entitlement.get("expiresAt"), now));
            Predicate matchedPredicate = planFilter == MemberPlanFilter.PRO_EXPIRING
                ? cb.and(isProActive, cb.lessThanOrEqualTo(entitlement.get("expiresAt"), now.plusDays(PRO_EXPIRING_WITHIN_DAYS)))
                : isProActive;
            entitlementSubquery.select(entitlement.get("memberUuid")).where(matchedPredicate);
            return root.get("memberUuid").in(entitlementSubquery);
        };
    }

    public static Specification<Member> excludeTest() {
        return (root, query, cb) -> cb.equal(root.get("isTestAccount"), false);
    }
}
