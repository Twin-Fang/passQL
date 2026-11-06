package com.passql.web.controller.admin;

import com.passql.submission.dto.mockexam.AdminMockExamAttemptRow;
import com.passql.submission.dto.mockexam.AdminMockExamComposeRequest;
import com.passql.submission.dto.mockexam.AdminMockExamComposeResult;
import com.passql.submission.dto.mockexam.AdminMockExamEligibleCount;
import com.passql.submission.dto.mockexam.AdminMockExamItemReplaceRequest;
import com.passql.submission.dto.mockexam.AdminMockExamItemStat;
import com.passql.submission.dto.mockexam.AdminMockExamPublishCheck;
import com.passql.submission.dto.mockexam.AdminMockExamRoundDetail;
import com.passql.submission.dto.mockexam.AdminMockExamRoundRow;
import com.passql.submission.service.MockExamAdminStatService;
import com.passql.submission.service.MockExamRoundAdminService;
import com.passql.submission.service.MockExamRoundComposer;
import com.passql.web.support.AdminPageRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

/**
 * 관리자 모의고사 API (#866): 회차 목록·자동 구성·상세·문항 교체·공개 검사·공개·보관·초안 되돌리기·삭제, 문항 통계, 응시 기록, 출제 가능 문제 수
 */
@RestController
@RequestMapping("/admin/api/mock-exams")
@RequiredArgsConstructor
public class AdminMockExamApiController implements AdminMockExamApiControllerDocs {

    private final MockExamRoundAdminService roundAdminService;
    private final MockExamRoundComposer roundComposer;
    private final MockExamAdminStatService adminStatService;

    @GetMapping("/rounds")
    public ResponseEntity<List<AdminMockExamRoundRow>> getRounds() {
        return ResponseEntity.ok(roundAdminService.getRounds());
    }

    @PostMapping("/rounds")
    public ResponseEntity<AdminMockExamComposeResult> compose(@RequestBody AdminMockExamComposeRequest request) {
        return ResponseEntity.ok(roundComposer.compose(request));
    }

    @GetMapping("/rounds/{roundUuid}")
    public ResponseEntity<AdminMockExamRoundDetail> getRoundDetail(@PathVariable UUID roundUuid) {
        return ResponseEntity.ok(roundAdminService.getRoundDetail(roundUuid));
    }

    @PostMapping("/rounds/{roundUuid}/items/{itemUuid}/replace")
    public ResponseEntity<Void> replaceItem(@PathVariable UUID roundUuid, @PathVariable UUID itemUuid,
                                            @RequestBody(required = false) AdminMockExamItemReplaceRequest request) {
        roundAdminService.replaceItem(roundUuid, itemUuid, request != null ? request.questionUuid() : null);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/rounds/{roundUuid}/publish-check")
    public ResponseEntity<AdminMockExamPublishCheck> checkPublish(@PathVariable UUID roundUuid) {
        return ResponseEntity.ok(roundAdminService.checkPublish(roundUuid));
    }

    @PostMapping("/rounds/{roundUuid}/publish")
    public ResponseEntity<Void> publish(@PathVariable UUID roundUuid) {
        roundAdminService.publish(roundUuid);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/rounds/{roundUuid}/archive")
    public ResponseEntity<Void> archive(@PathVariable UUID roundUuid) {
        roundAdminService.archive(roundUuid);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/rounds/{roundUuid}/revert-to-draft")
    public ResponseEntity<Void> revertToDraft(@PathVariable UUID roundUuid) {
        roundAdminService.revertToDraft(roundUuid);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/rounds/{roundUuid}")
    public ResponseEntity<Void> deleteDraft(@PathVariable UUID roundUuid) {
        roundAdminService.deleteDraft(roundUuid);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/rounds/{roundUuid}/item-stats")
    public ResponseEntity<List<AdminMockExamItemStat>> getItemStats(@PathVariable UUID roundUuid) {
        return ResponseEntity.ok(adminStatService.getItemStats(roundUuid));
    }

    @GetMapping("/attempts")
    public ResponseEntity<Page<AdminMockExamAttemptRow>> searchAttempts(
            @RequestParam(required = false) UUID roundUuid,
            @RequestParam(required = false) UUID memberUuid,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = AdminPageRequest.DEFAULT_PAGE_SIZE) int size) {
        return ResponseEntity.ok(adminStatService.searchAttempts(roundUuid, memberUuid,
            AdminPageRequest.of(page, size, Sort.unsorted())));
    }

    @GetMapping("/eligible-counts")
    public ResponseEntity<List<AdminMockExamEligibleCount>> getEligibleCounts() {
        return ResponseEntity.ok(adminStatService.getEligibleCounts());
    }
}
