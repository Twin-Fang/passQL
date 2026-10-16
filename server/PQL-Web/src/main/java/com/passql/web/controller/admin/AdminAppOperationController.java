package com.passql.web.controller.admin;

import com.passql.application.notification.MemberNotificationQueryService;
import com.passql.meta.dto.AppNoticeResponse;
import com.passql.meta.dto.AppNoticeSaveRequest;
import com.passql.meta.dto.AppOperationSettingsRequest;
import com.passql.meta.service.AppNoticeService;
import com.passql.meta.service.AppOperationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 관리자 앱 운영: 점검·버전 설정 저장, 공지 등록·수정·활성 전환 (#464)
 */
@Controller
@RequestMapping("/admin/app-operation")
@RequiredArgsConstructor
public class AdminAppOperationController {

    private final AppOperationService appOperationService;
    private final AppNoticeService appNoticeService;
    private final MemberNotificationQueryService memberNotificationQueryService;

    @GetMapping
    public String page(Model model) {
        List<AppNoticeResponse> notices = appNoticeService.getAllNotices();
        model.addAttribute("operationSettings", appOperationService.getOperationSettings());
        model.addAttribute("notices", notices);
        // 공지별 읽은 회원 수 (GROUP BY 1회)
        model.addAttribute("noticeReadCounts", memberNotificationQueryService.countReadMembersByNotice(
                notices.stream().map(AppNoticeResponse::noticeUuid).toList()));
        model.addAttribute("currentMenu", "app-operation");
        model.addAttribute("pageTitle", "앱 운영");
        return "admin/app-operation";
    }

    @PutMapping("/settings")
    @ResponseBody
    public ResponseEntity<Void> updateSettings(@RequestBody AppOperationSettingsRequest request) {
        appOperationService.updateOperationSettings(request);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/notices")
    @ResponseBody
    public ResponseEntity<AppNoticeResponse> createNotice(@RequestBody AppNoticeSaveRequest request) {
        return ResponseEntity.ok(appNoticeService.createNotice(request));
    }

    @PutMapping("/notices/{noticeUuid}")
    @ResponseBody
    public ResponseEntity<AppNoticeResponse> updateNotice(@PathVariable UUID noticeUuid,
                                                          @RequestBody AppNoticeSaveRequest request) {
        return ResponseEntity.ok(appNoticeService.updateNotice(noticeUuid, request));
    }

    /** 활성 전환 — 본문 {isActive: boolean} */
    @PutMapping("/notices/{noticeUuid}/active")
    @ResponseBody
    public ResponseEntity<Void> changeNoticeActive(@PathVariable UUID noticeUuid,
                                                   @RequestBody Map<String, Boolean> body) {
        appNoticeService.changeNoticeActive(noticeUuid, Boolean.TRUE.equals(body.get("isActive")));
        return ResponseEntity.ok().build();
    }
}
