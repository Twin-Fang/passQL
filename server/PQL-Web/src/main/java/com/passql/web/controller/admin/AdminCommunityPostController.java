package com.passql.web.controller.admin;

import com.passql.application.community.CommunityAdminService;
import com.passql.question.constant.CommunityBoardType;
import com.passql.question.constant.CommunityAdminPostSort;
import com.passql.question.constant.CommunityPostStatus;
import com.passql.question.dto.community.AdminCommunityPostListPage;
import com.passql.web.support.AdminPageRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;

/** 관리자 토론 게시글 목록 API (#557, #627): 게시판·상태·키워드·작성자·기간·신고 수 필터와 정렬 (처리는 신고 API 재사용) */
@RestController
@RequestMapping("/admin/api/community/posts")
@RequiredArgsConstructor
public class AdminCommunityPostController implements AdminCommunityPostControllerDocs {

    private final CommunityAdminService communityAdminService;

    @GetMapping
    public ResponseEntity<AdminCommunityPostListPage> getPosts(
            @RequestParam(required = false) CommunityBoardType boardType,
            @RequestParam(required = false) CommunityPostStatus status,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String author,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fromDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate toDate,
            @RequestParam(required = false) Integer minimumReportCount,
            @RequestParam(required = false) CommunityAdminPostSort sort,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = AdminPageRequest.DEFAULT_PAGE_SIZE) int size) {
        return ResponseEntity.ok(communityAdminService.getPosts(boardType, status, keyword, author, fromDate, toDate,
                minimumReportCount, sort, AdminPageRequest.of(page, size, Sort.unsorted())));
    }
}
