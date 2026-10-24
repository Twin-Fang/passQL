package com.passql.question.dto.community;

import java.util.List;

/**
 * 관리자 회원 상세의 커뮤니티 활동: 작성 글(최근 N건)과 이 회원이 한 신고(최근 N건)
 * totalPostCount: 작성 글 전체 수 (삭제 글 포함)
 */
public record AdminMemberCommunityActivity(
        List<AdminCommunityPostListItem> posts,
        long totalPostCount,
        List<AdminMemberFiledReportItem> filedReports
) {
}
