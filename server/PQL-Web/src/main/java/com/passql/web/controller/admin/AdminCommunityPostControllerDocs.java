package com.passql.web.controller.admin;

import com.passql.common.dto.Author;
import com.passql.question.constant.CommunityBoardType;
import com.passql.question.constant.CommunityPostStatus;
import com.passql.question.dto.community.AdminCommunityPostListPage;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;

@Tag(name = "Admin - Community Post", description = "관리자 토론 게시글 목록 (숨김·복원·삭제는 /admin/api/community/reports/{postUuid}/**)")
public interface AdminCommunityPostControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.10.20", author = Author.SUHSAECHAN, issueNumber = 557, description = "토론 게시글 목록 API 추가"),
    })
    @Operation(summary = "토론 게시글 목록", description = """
            - **boardType**: QUESTION_OPINION / EXAM_REVIEW / FREE / QNA (선택)
            - **status**: VISIBLE / HIDDEN_AUTO / HIDDEN_ADMIN / DELETED (선택, 미지정이면 삭제 글 제외)
            - **keyword**: 본문 부분 일치 (선택)
            - **page**, **size**: 기본 0, 20 (최대 100), 최신 작성순
            """)
    ResponseEntity<AdminCommunityPostListPage> getPosts(CommunityBoardType boardType, CommunityPostStatus status,
                                                        String keyword, int page, int size);
}
