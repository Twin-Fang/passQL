package com.passql.web.controller.admin;

import com.passql.application.feedback.FeedbackAdminService;
import com.passql.application.feedback.FeedbackAttachmentReader;
import com.passql.application.storage.ObjectStorageException;
import com.passql.meta.constant.FeedbackStatus;
import com.passql.meta.dto.FeedbackBulkStatusRequest;
import com.passql.meta.dto.FeedbackMemoUpdateRequest;
import com.passql.meta.dto.FeedbackSearchCondition;
import com.passql.meta.dto.FeedbackStatusUpdateRequest;
import com.passql.meta.entity.Feedback;
import com.passql.meta.entity.FeedbackImage;
import com.passql.meta.service.FeedbackService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import com.passql.web.support.AdminPageRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.PutMapping;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Controller
@RequestMapping("/admin/feedbacks")
@RequiredArgsConstructor
public class AdminFeedbackController {

    private final FeedbackService feedbackService;
    private final FeedbackAdminService feedbackAdminService;
    private final FeedbackAttachmentReader feedbackAttachmentReader;

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

    /** 의견 상세: 본문, 상태·메모, 이미지, 진단 표, 로그 (저장소를 못 읽어도 화면은 열림) */
    @GetMapping("/{feedbackUuid}")
    @AdminPage(menu = AdminMenu.FEEDBACKS, title = "의견 상세")
    public String detail(@PathVariable UUID feedbackUuid, Model model) {
        Feedback feedback = feedbackService.getFeedback(feedbackUuid);
        List<FeedbackImage> images = feedbackAttachmentReader.findImages(feedbackUuid);
        boolean hasAttachment = !images.isEmpty() || feedback.hasLog();
        boolean isAttachmentUnavailable = hasAttachment && !feedbackAttachmentReader.isStorageEnabled();
        String logText = null;
        if (feedback.hasLog() && !isAttachmentUnavailable) {
            try {
                logText = feedbackAttachmentReader.readLogText(feedbackUuid).orElse(null);
            } catch (ObjectStorageException e) {
                log.warn("[feedback admin] log read failed : feedback={}, cause={}", feedbackUuid, e.getMessage());
                isAttachmentUnavailable = true;
            }
        }
        model.addAttribute("feedback", feedback);
        model.addAttribute("memberNickname", feedbackAdminService.findMemberNickname(feedback.getMemberUuid()));
        model.addAttribute("statuses", FeedbackStatus.values());
        model.addAttribute("imageSortOrders", images.stream().map(FeedbackImage::getSortOrder).toList());
        model.addAttribute("diagnosticsGroups", feedbackAttachmentReader.groupDiagnostics(feedback));
        model.addAttribute("logText", logText);
        model.addAttribute("isAttachmentUnavailable", isAttachmentUnavailable);
        return "admin/feedback-detail";
    }

    /** 첨부 이미지 원본 중계 (WebP), 저장소 오류는 503 */
    @GetMapping("/{feedbackUuid}/images/{sortOrder}")
    public ResponseEntity<byte[]> image(@PathVariable UUID feedbackUuid, @PathVariable int sortOrder) {
        try {
            return ResponseEntity.ok().contentType(MediaType.parseMediaType("image/webp"))
                .body(feedbackAttachmentReader.readImage(feedbackUuid, sortOrder));
        } catch (ObjectStorageException e) {
            log.warn("[feedback admin] image read failed : feedback={}, sortOrder={}", feedbackUuid, sortOrder);
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).build();
        }
    }

    /** 앱 로그 gzip 다운로드, 저장소 오류는 503 */
    @GetMapping("/{feedbackUuid}/log")
    public ResponseEntity<byte[]> downloadLog(@PathVariable UUID feedbackUuid) {
        try {
            byte[] gzipBytes = feedbackAttachmentReader.readLogGzip(feedbackUuid);
            return ResponseEntity.ok().contentType(MediaType.parseMediaType("application/gzip"))
                .header(HttpHeaders.CONTENT_DISPOSITION, ContentDisposition.attachment()
                    .filename("feedback-" + feedbackUuid + "-app-log.txt.gz").build().toString())
                .body(gzipBytes);
        } catch (ObjectStorageException e) {
            log.warn("[feedback admin] log download failed : feedback={}", feedbackUuid);
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).build();
        }
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
        feedbackAdminService.changeStatus(feedbackUuid, FeedbackStatus.fromRequestValue(request.getStatus()));
        return ResponseEntity.ok().build();
    }

    /** 일괄 상태 변경 (최대 100건) > 변경한 건수 */
    @PostMapping("/bulk-status")
    @ResponseBody
    public Map<String, Integer> bulkUpdateStatus(@Valid @RequestBody FeedbackBulkStatusRequest request) {
        int changedCount = feedbackAdminService.changeStatuses(request.feedbackUuids(),
            FeedbackStatus.fromRequestValue(request.status()));
        return Map.of("changedCount", changedCount);
    }
}
