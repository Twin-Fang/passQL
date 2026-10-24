package com.passql.web.controller.admin;

import com.passql.application.notification.MemberNotificationQueryService;
import com.passql.meta.dto.AdminAppNoticeResponse;
import com.passql.meta.dto.AppNoticeResponse;
import com.passql.meta.dto.AppNoticeSaveRequest;
import com.passql.meta.dto.AppOperationSettingsRequest;
import com.passql.meta.service.AppNoticeService;
import com.passql.meta.service.AppOperationChangeHistoryService;
import com.passql.meta.service.AppOperationService;
import com.passql.member.service.PushNotificationService;
import com.passql.web.service.AdminNoticePushService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 관리자 앱 운영: 점검(예약 포함)·버전 설정 저장, 설정 변경 이력, 공지 등록·수정·삭제·활성 전환 (#464, #630)
 */
@Controller
@RequestMapping("/admin/app-operation")
@RequiredArgsConstructor
public class AdminAppOperationController {

    private final AppOperationService appOperationService;
    private final AppNoticeService appNoticeService;
    private final MemberNotificationQueryService memberNotificationQueryService;
    private final PushNotificationService pushNotificationService;
    private final AppOperationChangeHistoryService appOperationChangeHistoryService;
    private final AdminNoticePushService adminNoticePushService;

    @GetMapping
    public String page(Model model) {
        List<AdminAppNoticeResponse> notices = appNoticeService.getAllNotices();
        // 공지별 읽은 회원 수 (GROUP BY 1회)
        Map<UUID, Long> readCountByNoticeUuid = memberNotificationQueryService.countReadMembersByNotice(
                notices.stream().map(AdminAppNoticeResponse::noticeUuid).toList());
        // 읽음률 분모: 알림함 대상 회원 수 (탈퇴 제외)
        long noticeAudienceCount = pushNotificationService.countAllInboxRecipients();
        model.addAttribute("operationSettings", appOperationService.getOperationSettings());
        model.addAttribute("notices", notices);
        model.addAttribute("noticeReadCounts", readCountByNoticeUuid);
        model.addAttribute("noticeAudienceCount", noticeAudienceCount);
        model.addAttribute("noticeReadRatePercents", toReadRatePercents(readCountByNoticeUuid, noticeAudienceCount));
        model.addAttribute("settingChanges", appOperationChangeHistoryService.findRecentChanges());
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

    /** 공지 등록: sendPush=true 면 저장 뒤 전체 푸시 (결과는 pushResult 로 응답, 푸시 실패가 등록을 되돌리지 않음) */
    @PostMapping("/notices")
    @ResponseBody
    public Map<String, Object> createNotice(@RequestBody AppNoticeSaveRequest request,
                                            @RequestParam(defaultValue = "false") boolean sendPush,
                                            Principal principal) {
        AppNoticeResponse notice = appNoticeService.createNotice(request);
        AdminNoticePushService.NoticePushResult pushResult = sendPush
                ? adminNoticePushService.sendNoticePush(notice, principal.getName())
                : AdminNoticePushService.NoticePushResult.SKIPPED;
        return Map.of("notice", notice, "pushResult", pushResult.name());
    }

    @PutMapping("/notices/{noticeUuid}")
    @ResponseBody
    public ResponseEntity<AppNoticeResponse> updateNotice(@PathVariable UUID noticeUuid,
                                                          @RequestBody AppNoticeSaveRequest request) {
        return ResponseEntity.ok(appNoticeService.updateNotice(noticeUuid, request));
    }

    /** 공지 삭제: 공지 행 > 읽음 기록 정리 (되돌릴 수 없음, 숨기려면 비활성화) */
    @DeleteMapping("/notices/{noticeUuid}")
    @ResponseBody
    public ResponseEntity<Void> deleteNotice(@PathVariable UUID noticeUuid) {
        appNoticeService.deleteNotice(noticeUuid);
        memberNotificationQueryService.deleteNoticeReads(noticeUuid);
        return ResponseEntity.ok().build();
    }

    /** 활성 전환 — 본문 {isActive: boolean} */
    @PutMapping("/notices/{noticeUuid}/active")
    @ResponseBody
    public ResponseEntity<Void> changeNoticeActive(@PathVariable UUID noticeUuid,
                                                   @RequestBody Map<String, Boolean> body) {
        appNoticeService.changeNoticeActive(noticeUuid, Boolean.TRUE.equals(body.get("isActive")));
        return ResponseEntity.ok().build();
    }

    /** 공지별 읽음률(%): 읽은 회원 수 * 100 / 대상 회원 수 (대상 0명이면 0) */
    private static Map<UUID, Long> toReadRatePercents(Map<UUID, Long> readCountByNoticeUuid, long audienceCount) {
        Map<UUID, Long> readRatePercentByNoticeUuid = new HashMap<>();
        readCountByNoticeUuid.forEach((noticeUuid, readCount) ->
                readRatePercentByNoticeUuid.put(noticeUuid, audienceCount == 0 ? 0 : readCount * 100 / audienceCount));
        return readRatePercentByNoticeUuid;
    }
}
