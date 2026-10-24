package com.passql.question.repository;

import com.passql.question.constant.CommunityBoardType;
import com.passql.question.constant.CommunityPostStatus;
import com.passql.question.constant.CommunityReportCategory;
import com.passql.question.constant.CommunityReportStatus;
import com.passql.question.constant.CommunityReportTargetType;
import com.passql.question.entity.CommunityPost;
import com.passql.question.entity.CommunityReport;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;
import org.springframework.data.jpa.domain.Specification;

import java.time.LocalDate;
import java.util.Collection;
import java.util.UUID;

/** 관리자 글·신고 목록 조건: 게시판, 상태, 본문 키워드, 작성자, 기간, 신고 수, 신고 사유 (null·빈 값은 조건 없음) */
public final class CommunityPostSpecification {

    private CommunityPostSpecification() {
    }

    public static Specification<CommunityPost> boardTypeEquals(CommunityBoardType boardType) {
        return (root, query, criteriaBuilder) ->
                boardType == null ? criteriaBuilder.conjunction() : criteriaBuilder.equal(root.get("boardType"), boardType);
    }

    /** 상태 지정 > 그 상태만, 미지정 > 삭제 글 제외 */
    public static Specification<CommunityPost> statusEqualsOrNotDeleted(CommunityPostStatus status) {
        return (root, query, criteriaBuilder) -> status == null
                ? criteriaBuilder.notEqual(root.get("status"), CommunityPostStatus.DELETED)
                : criteriaBuilder.equal(root.get("status"), status);
    }

    /** 작성자 후보 회원들 중 한 명이 쓴 글 (null 이면 조건 없음, 빈 집합이면 결과 없음) */
    public static Specification<CommunityPost> authorIn(Collection<UUID> authorMemberUuids) {
        return (root, query, criteriaBuilder) -> {
            if (authorMemberUuids == null) {
                return criteriaBuilder.conjunction();
            }
            return authorMemberUuids.isEmpty() ? criteriaBuilder.disjunction() : root.get("authorMemberUuid").in(authorMemberUuids);
        };
    }

    /** 작성일 시작일 이상 (당일 00:00 부터) */
    public static Specification<CommunityPost> createdFrom(LocalDate fromDate) {
        return (root, query, criteriaBuilder) -> fromDate == null ? criteriaBuilder.conjunction()
                : criteriaBuilder.greaterThanOrEqualTo(root.get("createdAt"), fromDate.atStartOfDay());
    }

    /** 작성일 종료일 이하 (당일 끝까지) */
    public static Specification<CommunityPost> createdTo(LocalDate toDate) {
        return (root, query, criteriaBuilder) -> toDate == null ? criteriaBuilder.conjunction()
                : criteriaBuilder.lessThan(root.get("createdAt"), toDate.plusDays(1).atStartOfDay());
    }

    /** 검토 대기 신고 수 하한 (null·0 이하면 조건 없음) */
    public static Specification<CommunityPost> reportCountAtLeast(Integer minimumReportCount) {
        return (root, query, criteriaBuilder) -> minimumReportCount == null || minimumReportCount <= 0
                ? criteriaBuilder.conjunction()
                : criteriaBuilder.greaterThanOrEqualTo(root.get("reportCount"), minimumReportCount);
    }

    /** 신고 목록 기본 조건: 삭제 제외 + (대기만이면 검토 대기 신고 있는 글, 아니면 신고 있거나 숨겨진 글) */
    public static Specification<CommunityPost> reportedPosts(boolean isPendingOnly) {
        return (root, query, criteriaBuilder) -> {
            Predicate isNotDeleted = criteriaBuilder.notEqual(root.get("status"), CommunityPostStatus.DELETED);
            Predicate hasPendingReports = criteriaBuilder.greaterThan(root.get("reportCount"), 0);
            if (isPendingOnly) {
                return criteriaBuilder.and(isNotDeleted, hasPendingReports);
            }
            Predicate isHidden = root.get("status").in(CommunityPostStatus.HIDDEN_AUTO, CommunityPostStatus.HIDDEN_ADMIN);
            return criteriaBuilder.and(isNotDeleted, criteriaBuilder.or(hasPendingReports, isHidden));
        };
    }

    /** 특정 사유의 신고가 달린 글 (대기만이면 검토 대기 신고 중에서) */
    public static Specification<CommunityPost> hasReportOfCategory(CommunityReportCategory category, boolean isPendingOnly) {
        return (root, query, criteriaBuilder) -> {
            if (category == null) {
                return criteriaBuilder.conjunction();
            }
            Subquery<UUID> reportSubquery = query.subquery(UUID.class);
            Root<CommunityReport> report = reportSubquery.from(CommunityReport.class);
            Predicate matchedReport = criteriaBuilder.and(
                    criteriaBuilder.equal(report.get("targetType"), CommunityReportTargetType.POST),
                    criteriaBuilder.equal(report.get("targetUuid"), root.get("postUuid")),
                    criteriaBuilder.equal(report.get("category"), category));
            if (isPendingOnly) {
                matchedReport = criteriaBuilder.and(matchedReport,
                        criteriaBuilder.equal(report.get("status"), CommunityReportStatus.PENDING));
            }
            reportSubquery.select(report.get("reportUuid")).where(matchedReport);
            return criteriaBuilder.exists(reportSubquery);
        };
    }

    // LIKE 이스케이프 문자 (키워드의 %, _ 를 글자 그대로 찾게)
    private static final char LIKE_ESCAPE_CHARACTER = '\\';

    /** 본문 부분 일치 (대소문자 무시, %·_ 는 글자 그대로) */
    public static Specification<CommunityPost> contentContains(String keyword) {
        return (root, query, criteriaBuilder) -> keyword == null || keyword.isBlank()
                ? criteriaBuilder.conjunction()
                : criteriaBuilder.like(criteriaBuilder.lower(root.get("content")),
                        "%" + escapeLikePattern(keyword.trim().toLowerCase()) + "%", LIKE_ESCAPE_CHARACTER);
    }

    // \ > \\, % > \%, _ > \_
    private static String escapeLikePattern(String keyword) {
        return keyword.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
    }
}
