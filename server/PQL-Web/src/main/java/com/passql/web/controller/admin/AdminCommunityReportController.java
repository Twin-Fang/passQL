package com.passql.web.controller.admin;

import com.passql.application.community.CommunityAdminService;
import com.passql.question.constant.CommunityModerationAction;
import com.passql.question.constant.CommunityAdminPostSort;
import com.passql.question.constant.CommunityReportCategory;
import com.passql.question.dto.community.AdminCommunityPostPage;
import com.passql.question.dto.community.AdminCommunityReportStats;
import com.passql.question.dto.community.CommunityBulkModerationRequest;
import com.passql.question.dto.community.CommunityBulkResultResponse;
import com.passql.question.dto.community.CommunityModerationRequest;
import com.passql.web.support.AdminPageRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;
import java.util.UUID;

/**
 * 관리자 커뮤니티 신고 API: 신고 글 목록·통계, 숨김·복원·삭제·기각(글 단위·일괄), 신고 1건 기각
 * 처리자 = 로그인한 관리자 아이디, 처리 사유 메모는 선택 본문(reason)
 */
@RestController
@RequestMapping("/admin/api/community/reports")
@RequiredArgsConstructor
public class AdminCommunityReportController {

    private final CommunityAdminService communityAdminService;

    @GetMapping
    public ResponseEntity<AdminCommunityPostPage> getReportedPosts(
            @RequestParam(defaultValue = "true") boolean pendingOnly,
            @RequestParam(required = false) CommunityReportCategory category,
            @RequestParam(required = false) CommunityAdminPostSort sort,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = AdminPageRequest.DEFAULT_PAGE_SIZE) int size) {
        return ResponseEntity.ok(communityAdminService.getReportedPosts(pendingOnly, category, sort,
                AdminPageRequest.of(page, size, Sort.unsorted())));
    }

    /** 처리 통계: 대기 신고 수, 최근 30일 처리 건수, 평균 처리 시간 */
    @GetMapping("/stats")
    public ResponseEntity<AdminCommunityReportStats> getReportStats() {
        return ResponseEntity.ok(communityAdminService.getReportStats());
    }

    @PostMapping("/{postUuid}/hide")
    public ResponseEntity<Void> hidePost(@PathVariable UUID postUuid,
                                         @Valid @RequestBody(required = false) CommunityModerationRequest request,
                                         Principal adminPrincipal) {
        communityAdminService.hidePost(postUuid, adminPrincipal.getName(), toHandledNote(request));
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{postUuid}/restore")
    public ResponseEntity<Void> restorePost(@PathVariable UUID postUuid,
                                            @Valid @RequestBody(required = false) CommunityModerationRequest request,
                                            Principal adminPrincipal) {
        communityAdminService.restorePost(postUuid, adminPrincipal.getName(), toHandledNote(request));
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{postUuid}/delete")
    public ResponseEntity<Void> deletePost(@PathVariable UUID postUuid,
                                           @Valid @RequestBody(required = false) CommunityModerationRequest request,
                                           Principal adminPrincipal) {
        communityAdminService.deletePost(postUuid, adminPrincipal.getName(), toHandledNote(request));
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{postUuid}/dismiss")
    public ResponseEntity<Void> dismissReports(@PathVariable UUID postUuid,
                                               @Valid @RequestBody(required = false) CommunityModerationRequest request,
                                               Principal adminPrincipal) {
        communityAdminService.dismissReports(postUuid, adminPrincipal.getName(), toHandledNote(request));
        return ResponseEntity.ok().build();
    }

    /** 신고 1건만 기각 (글 상태는 그대로, 글의 대기 신고 수만 1 차감) */
    @PostMapping("/items/{reportUuid}/dismiss")
    public ResponseEntity<Void> dismissReport(@PathVariable UUID reportUuid,
                                              @Valid @RequestBody(required = false) CommunityModerationRequest request,
                                              Principal adminPrincipal) {
        communityAdminService.dismissReport(reportUuid, adminPrincipal.getName(), toHandledNote(request));
        return ResponseEntity.ok().build();
    }

    /** 글 일괄 처리: action = hide | restore | delete | dismiss (최대 100건) */
    @PostMapping("/bulk")
    public ResponseEntity<CommunityBulkResultResponse> moderatePosts(@RequestParam String action,
                                                                     @Valid @RequestBody CommunityBulkModerationRequest request,
                                                                     Principal adminPrincipal) {
        return ResponseEntity.ok(communityAdminService.moderatePosts(CommunityModerationAction.fromPathValue(action),
                request.postUuids(), adminPrincipal.getName(), request.reason()));
    }

    private static String toHandledNote(CommunityModerationRequest request) {
        return request == null ? null : request.reason();
    }
}
