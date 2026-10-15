package com.passql.web.controller.admin;

import com.passql.meta.constant.FeedbackStatus;
import com.passql.meta.dto.FeedbackMemoUpdateRequest;
import com.passql.meta.dto.FeedbackStatusUpdateRequest;
import com.passql.meta.service.FeedbackService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import com.passql.web.support.AdminPageRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.PutMapping;

import java.util.UUID;

@Controller
@RequestMapping("/admin/feedbacks")
@RequiredArgsConstructor
public class AdminFeedbackController {

    private final FeedbackService feedbackService;

    @GetMapping
    @AdminPage(menu = AdminMenu.FEEDBACKS)
    public String list(Model model,
                       @RequestParam(required = false) String status,
                       @RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = AdminPageRequest.DEFAULT_PAGE_SIZE) int size) {
        // 정렬은 Repository 메서드명(OrderByCreatedAtDesc)에서 처리
        Pageable pageable = AdminPageRequest.of(page, size, Sort.unsorted());
        FeedbackStatus selectedStatus = (status == null || status.isBlank()) ? null : FeedbackStatus.fromRequestValue(status);

        var statusCounts = feedbackService.countByStatus();
        model.addAttribute("feedbacks", feedbackService.getFeedbacksForAdmin(selectedStatus, pageable));
        model.addAttribute("selectedStatus", selectedStatus);
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
}
