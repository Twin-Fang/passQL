package com.passql.web.controller.admin;

import com.passql.common.dto.Author;
import com.passql.question.constant.CommunityBoardType;
import com.passql.question.constant.CommunityAdminPostSort;
import com.passql.question.constant.CommunityPostStatus;
import com.passql.question.dto.community.AdminCommunityPostListPage;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;

import java.time.LocalDate;

@Tag(name = "Admin - Community Post", description = "관리자 토론 게시글 목록 (숨김·복원·삭제는 /admin/api/community/reports/{postUuid}/**)")
public interface AdminCommunityPostControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.10.20", author = Author.SUHSAECHAN, issueNumber = 557, description = "토론 게시글 목록 API 추가"),
        @ApiLog(date = "2026.10.24", author = Author.SUHSAECHAN, issueNumber = 627, description = "토론 게시글 목록 작성자·기간·신고 수 필터와 정렬 추가"),
    })
    @Operation(summary = "토론 게시글 목록", description = """
            - **boardType**: QUESTION_OPINION / EXAM_REVIEW / FREE / QNA (선택)
            - **status**: VISIBLE / HIDDEN_AUTO / HIDDEN_ADMIN / DELETED (선택, 미지정이면 삭제 글 제외)
            - **keyword**: 본문 부분 일치 (선택)
            - **author**: 작성자 UUID 또는 닉네임 부분 일치 (선택)
            - **fromDate**, **toDate**: 작성일 범위 yyyy-MM-dd (선택)
            - **minimumReportCount**: 검토 대기 신고 수 하한 (선택)
            - **sort**: NEWEST(기본) / OLDEST / MOST_REPORTED / MOST_LIKED
            - **page**, **size**: 기본 0, 20 (최대 100)
            """)
    ResponseEntity<AdminCommunityPostListPage> getPosts(CommunityBoardType boardType, CommunityPostStatus status,
                                                        String keyword, String author, LocalDate fromDate,
                                                        LocalDate toDate, Integer minimumReportCount,
                                                        CommunityAdminPostSort sort, int page, int size);
}
