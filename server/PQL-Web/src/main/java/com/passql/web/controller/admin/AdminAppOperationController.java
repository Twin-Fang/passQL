package com.passql.web.controller.admin;

import com.passql.application.billing.BillingOperationService;
import com.passql.application.billing.BillingPreviewMemberRequest;
import com.passql.application.billing.BillingSwitchRequest;
import com.passql.application.notification.MemberNotificationQueryService;
import com.passql.meta.dto.AdminAppNoticeResponse;
import com.passql.meta.dto.AppNoticeActiveRequest;
import com.passql.meta.dto.AppNoticeResponse;
import com.passql.meta.dto.AppNoticeSaveRequest;
import com.passql.meta.dto.AppOperationSettingsRequest;
import com.passql.meta.service.AppNoticeService;
import com.passql.meta.service.AppOperationChangeHistoryService;
import com.passql.meta.service.AppOperationService;
import com.passql.member.service.PushNotificationService;
import com.passql.web.service.AdminNoticePushService;
import jakarta.validation.Valid;
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
 * 관리자 앱 운영: 점검(예약 포함)·버전 설정 저장, 결제 스위치·미리보기 회원·켜기 전 점검표, 설정 변경 이력, 공지 등록·수정·삭제·활성 전환 (#464, #630, #961)
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
    private final BillingOperationService billingOperationService;

    @GetMapping
    public String page(Model model) {
        List<AdminAppNoticeResponse> notices = appNoticeService.getAllNotices();
        // 공지별 읽은 회원 수 (GROUP BY 1회)
        Map<UUID, Long> readCountByNoticeUuid = memberNotificationQueryService.countReadMembersByNotice(
                notices.stream().map(AdminAppNoticeResponse::noticeUuid).toList());
        // 읽음률 분모: 알림함 대상 회원 수 (탈퇴 제외)
        long noticeAudienceCount = pushNotificationService.countAllInboxRecipients();
        model.addAttribute("operationSettings", appOperationService.getOperationSettings());
        model.addAttribute("billingOperation", billingOperationService.getBillingOperationView());
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

    /** 결제 스위치 전환 — 본문 {isEnabled: boolean} (점검표 미충족이어도 저장, 확인은 화면 확인 창) */
    @PutMapping("/billing/enabled")
    @ResponseBody
    public ResponseEntity<Void> changeBillingEnabled(@Valid @RequestBody BillingSwitchRequest request) {
        billingOperationService.changeBillingEnabled(request.isEnabled());
        return ResponseEntity.ok().build();
    }

    /** 결제 미리보기 회원 추가 — 본문 {memberUuid} (형식 오류 400, 없는 회원 404) */
    @PostMapping("/billing/preview-members")
    @ResponseBody
    public ResponseEntity<Void> addBillingPreviewMember(@Valid @RequestBody BillingPreviewMemberRequest request) {
        billingOperationService.addPreviewMember(request.memberUuid());
        return ResponseEntity.ok().build();
    }

    /** 결제 미리보기 항목 삭제 — 본문 {memberUuid: 목록에 저장된 항목 원문} */
    @DeleteMapping("/billing/preview-members")
    @ResponseBody
    public ResponseEntity<Void> removeBillingPreviewMember(@Valid @RequestBody BillingPreviewMemberRequest request) {
        billingOperationService.removePreviewMember(request.memberUuid());
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
                                                   @Valid @RequestBody AppNoticeActiveRequest request) {
        appNoticeService.changeNoticeActive(noticeUuid, request.isActive());
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
