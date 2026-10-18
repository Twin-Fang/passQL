package com.passql.web.controller.admin;

import com.passql.application.community.CommunityAdminService;
import com.passql.question.dto.community.AdminCommunityPostPage;
import com.passql.web.support.AdminPageRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;
import java.util.UUID;

/** 관리자 커뮤니티 신고 API: 신고 글 목록, 숨김·복원·삭제·신고 기각 (처리자 = 로그인한 관리자 아이디) */
@RestController
@RequestMapping("/admin/api/community/reports")
@RequiredArgsConstructor
public class AdminCommunityReportController {

    private final CommunityAdminService communityAdminService;

    @GetMapping
    public ResponseEntity<AdminCommunityPostPage> getReportedPosts(
            @RequestParam(defaultValue = "true") boolean pendingOnly,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = AdminPageRequest.DEFAULT_PAGE_SIZE) int size) {
        return ResponseEntity.ok(communityAdminService.getReportedPosts(pendingOnly, AdminPageRequest.of(page, size, Sort.unsorted())));
    }

    @PostMapping("/{postUuid}/hide")
    public ResponseEntity<Void> hidePost(@PathVariable UUID postUuid, Principal adminPrincipal) {
        communityAdminService.hidePost(postUuid, adminPrincipal.getName());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{postUuid}/restore")
    public ResponseEntity<Void> restorePost(@PathVariable UUID postUuid, Principal adminPrincipal) {
        communityAdminService.restorePost(postUuid, adminPrincipal.getName());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{postUuid}/delete")
    public ResponseEntity<Void> deletePost(@PathVariable UUID postUuid, Principal adminPrincipal) {
        communityAdminService.deletePost(postUuid, adminPrincipal.getName());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{postUuid}/dismiss")
    public ResponseEntity<Void> dismissReports(@PathVariable UUID postUuid, Principal adminPrincipal) {
        communityAdminService.dismissReports(postUuid, adminPrincipal.getName());
        return ResponseEntity.ok().build();
    }
}
