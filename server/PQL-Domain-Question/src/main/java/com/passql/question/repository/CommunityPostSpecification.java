package com.passql.question.repository;

import com.passql.question.constant.CommunityBoardType;
import com.passql.question.constant.CommunityPostStatus;
import com.passql.question.entity.CommunityPost;
import org.springframework.data.jpa.domain.Specification;

/** 관리자 게시글 목록 조건 3개: 게시판, 상태(미지정이면 삭제 제외), 본문 키워드 (null·빈 값은 조건 없음) */
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
