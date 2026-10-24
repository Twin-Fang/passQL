package com.passql.web.controller.admin;

import com.passql.application.feedback.FeedbackAdminService;
import com.passql.meta.constant.FeedbackStatus;
import com.passql.meta.dto.FeedbackBulkStatusRequest;
import com.passql.meta.dto.FeedbackMemoUpdateRequest;
import com.passql.meta.dto.FeedbackReplyRequest;
import com.passql.meta.dto.FeedbackSearchCondition;
import com.passql.meta.dto.FeedbackStatusUpdateRequest;
import com.passql.meta.service.FeedbackService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import com.passql.web.support.AdminPageRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.PutMapping;

import java.util.Map;
import java.util.UUID;

@Controller
@RequestMapping("/admin/feedbacks")
@RequiredArgsConstructor
public class AdminFeedbackController {

    private final FeedbackService feedbackService;
    private final FeedbackAdminService feedbackAdminService;

    /** 건의 목록 (#628): 상태·키워드·회원(UUID·닉네임)·기간 검색, 최신순 */
    @GetMapping
    @AdminPage(menu = AdminMenu.FEEDBACKS)
    public String list(Model model, FeedbackSearchCondition condition,
                       @RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = AdminPageRequest.DEFAULT_PAGE_SIZE) int size) {
        // 정렬은 FeedbackService 검색에서 처리 (createdAt DESC)
        Pageable pageable = AdminPageRequest.of(page, size, Sort.unsorted());

        var statusCounts = feedbackService.countByStatus();
        model.addAttribute("feedbacks", feedbackAdminService.searchFeedbacks(condition, pageable));
        model.addAttribute("condition", condition);
        model.addAttribute("statuses", FeedbackStatus.values());
        model.addAttribute("pendingCount", statusCounts.get(FeedbackStatus.PENDING));
        model.addAttribute("reviewedCount", statusCounts.get(FeedbackStatus.REVIEWED));
        model.addAttribute("appliedCount", statusCounts.get(FeedbackStatus.APPLIED));
        return "admin/feedbacks";
    }

    /** 관리자 메모 저장 (#479, 앱 미노출) */
    @PutMapping("/{feedbackUuid}/memo")
    @ResponseBody
    public ResponseEntity<Void> updateMemo(@PathVariable UUID feedbackUuid,
                                           @Valid @RequestBody FeedbackMemoUpdateRequest request) {
        feedbackService.updateAdminMemo(feedbackUuid, request.adminMemo());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{feedbackUuid}/status")
    @ResponseBody
    public ResponseEntity<Void> updateStatus(@PathVariable UUID feedbackUuid,
                                              @RequestBody FeedbackStatusUpdateRequest request) {
        feedbackService.updateStatus(feedbackUuid, FeedbackStatus.fromRequestValue(request.getStatus()));
        return ResponseEntity.ok().build();
    }

    /** 일괄 상태 변경 (최대 100건) > 변경한 건수 */
    @PostMapping("/bulk-status")
    @ResponseBody
    public Map<String, Integer> bulkUpdateStatus(@Valid @RequestBody FeedbackBulkStatusRequest request) {
        int changedCount = feedbackService.updateStatuses(request.feedbackUuids(),
            FeedbackStatus.fromRequestValue(request.status()));
        return Map.of("changedCount", changedCount);
    }

    /** 답변 발송: 작성자 알림함으로 전달 + 답변 기록 */
    @PostMapping("/{feedbackUuid}/reply")
    @ResponseBody
    public ResponseEntity<Void> reply(@PathVariable UUID feedbackUuid,
                                      @Valid @RequestBody FeedbackReplyRequest request) {
        feedbackAdminService.replyToFeedback(feedbackUuid, request.message());
        return ResponseEntity.ok().build();
    }
}
