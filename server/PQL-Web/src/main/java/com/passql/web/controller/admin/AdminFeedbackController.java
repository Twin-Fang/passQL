package com.passql.web.controller.admin;

import com.passql.web.support.AdminPageRequest;
import com.passql.meta.constant.FeedbackStatus;
import com.passql.meta.dto.FeedbackStatusUpdateRequest;
import com.passql.meta.service.FeedbackService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@Controller
@RequestMapping("/admin/feedbacks")
@RequiredArgsConstructor
public class AdminFeedbackController {

    private final FeedbackService feedbackService;

    @GetMapping
    public String list(Model model,
                       @RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = AdminPageRequest.DEFAULT_PAGE_SIZE) int size) {
        // 정렬은 findAllByOrderByCreatedAtDesc 메서드명에서 처리
        Pageable pageable = AdminPageRequest.of(page, size, Sort.unsorted());

        var statusCounts = feedbackService.countByStatus();
        model.addAttribute("feedbacks", feedbackService.getAllFeedbacks(pageable));
        model.addAttribute("statuses", FeedbackStatus.values());
        model.addAttribute("pendingCount", statusCounts.get(FeedbackStatus.PENDING));
        model.addAttribute("reviewedCount", statusCounts.get(FeedbackStatus.REVIEWED));
        model.addAttribute("appliedCount", statusCounts.get(FeedbackStatus.APPLIED));
        model.addAttribute("pageTitle", "건의사항 관리");
        model.addAttribute("currentMenu", "feedbacks");
        return "admin/feedbacks";
    }

    @PostMapping("/{feedbackUuid}/status")
    @ResponseBody
    public ResponseEntity<Void> updateStatus(@PathVariable UUID feedbackUuid,
                                              @RequestBody FeedbackStatusUpdateRequest request) {
        feedbackService.updateStatus(feedbackUuid, FeedbackStatus.fromRequestValue(request.getStatus()));
        return ResponseEntity.ok().build();
    }
}
