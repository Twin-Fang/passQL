package com.passql.web.controller.admin;

import com.passql.application.notification.MemberNotificationService;
import com.passql.application.notification.NotificationSettingService;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.NotificationDeliveryMode;
import com.passql.member.constant.PushAudience;
import com.passql.member.constant.PushDispatchStatus;
import com.passql.member.constant.PushLinkTarget;
import com.passql.member.dto.PushHistorySearchCondition;
import com.passql.member.dto.PushSendAcceptedResponse;
import com.passql.member.dto.PushSendRequest;
import com.passql.member.dto.PushTemplateSaveRequest;
import com.passql.member.service.PushNotificationService;
import com.passql.member.service.PushTemplateService;
import com.passql.web.dto.notification.NotificationSettingsRequest;
import com.passql.web.dto.notification.PushDeliveryFailureResponse;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import com.passql.web.support.AdminPageRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.security.Principal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 관리자 알림 발송 화면(탭 3개): 발송(세그먼트·예약·테스트·템플릿), 발송 이력(검색·실패 기기·열람률·회수·예약 취소), 알림 설정
 */
@Controller
@RequestMapping("/admin/push")
@RequiredArgsConstructor
public class AdminPushController {

    private final PushNotificationService pushNotificationService;
    private final MemberNotificationService memberNotificationService;
    private final NotificationSettingService notificationSettingService;
    private final PushTemplateService pushTemplateService;

    @GetMapping
    @AdminPage(menu = AdminMenu.PUSH)
    public String page(Model model,
                       @ModelAttribute("condition") PushHistorySearchCondition condition,
                       @RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = AdminPageRequest.DEFAULT_PAGE_SIZE) int size) {
        // 정렬은 searchHistories 가 발송(예약) 시각 최신순으로 고정
        model.addAttribute("histories", memberNotificationService.getHistoryRows(condition, AdminPageRequest.of(page, size, Sort.unsorted())));
        model.addAttribute("stats", memberNotificationService.getRecentStats(MemberNotificationService.DEFAULT_STATS_DAYS));
        model.addAttribute("templates", pushTemplateService.findAll());
        model.addAttribute("pushEnabledDeviceCount", pushNotificationService.countPushEnabledDevices());
        model.addAttribute("inboxRecipientCount", pushNotificationService.countAllInboxRecipients());
        model.addAttribute("audiences", PushAudience.values());
        model.addAttribute("dispatchStatuses", PushDispatchStatus.values());
        model.addAttribute("linkTargets", PushLinkTarget.values());
        model.addAttribute("deliveryModes", NotificationDeliveryMode.values());
        model.addAttribute("settings", notificationSettingService.getSettings());
        model.addAttribute("retentionMinDays", NotificationSettingService.MIN_RETENTION_DAYS);
        model.addAttribute("retentionMaxDays", NotificationSettingService.MAX_RETENTION_DAYS);
        return "admin/push";
    }

    @PostMapping("/send")
    @ResponseBody
    public PushSendAcceptedResponse send(@Valid @RequestBody PushSendRequest request, Principal principal) {
        return memberNotificationService.sendAdminMessage(request, principal.getName());
    }

    /** 테스트 발송: 지정 회원 1명에게 즉시 (대상·예약은 무시, 이력에 테스트로 표시되고 통계에서 제외) */
    @PostMapping("/test-send")
    @ResponseBody
    public PushSendAcceptedResponse testSend(@Valid @RequestBody PushSendRequest request, Principal principal) {
        PushSendRequest memberRequest = new PushSendRequest(request.getTitle(), request.getBody(), PushAudience.MEMBER.name(),
                request.getTargetMemberUuid(), request.getLinkTarget(), request.getLinkQuestionUuid(), request.getDeliveryMode());
        return memberNotificationService.sendAdminMessage(memberRequest, principal.getName(), true);
    }

    /** 대상 회원 수 미리보기 (발송 전 안내용, 세그먼트는 지금 기준) */
    @GetMapping("/audience-count")
    @ResponseBody
    public Map<String, Long> audienceCount(@RequestParam String audience, @RequestParam(required = false) Integer inactiveDays) {
        return Map.of("memberCount", memberNotificationService.countTargetMembers(PushAudience.fromRequestValue(audience), inactiveDays));
    }

    /** 발송 회수: 받은 회원들의 알림함에서 숨김 (이미 나간 푸시는 되돌릴 수 없음) */
    @PostMapping("/{pushSendHistoryUuid}/retract")
    @ResponseBody
    public Map<String, Integer> retract(@PathVariable UUID pushSendHistoryUuid, Principal principal) {
        int hiddenCount = memberNotificationService.retractAdminMessage(pushSendHistoryUuid, principal.getName());
        return Map.of("hiddenCount", hiddenCount);
    }

    /** 예약 취소 (발송 시각 전 예약 대기 건만) */
    @PostMapping("/{pushSendHistoryUuid}/cancel")
    @ResponseBody
    public ResponseEntity<Void> cancelScheduled(@PathVariable UUID pushSendHistoryUuid) {
        memberNotificationService.cancelScheduledSend(pushSendHistoryUuid);
        return ResponseEntity.ok().build();
    }

    /** 발송 실패 기기 목록 */
    @GetMapping("/{pushSendHistoryUuid}/failures")
    @ResponseBody
    public List<PushDeliveryFailureResponse> failures(@PathVariable UUID pushSendHistoryUuid) {
        return pushNotificationService.findFailures(pushSendHistoryUuid).stream().map(PushDeliveryFailureResponse::from).toList();
    }

    /** 템플릿 저장 (같은 이름이면 덮어쓰기) */
    @PostMapping("/templates")
    @ResponseBody
    public Map<String, UUID> saveTemplate(@Valid @RequestBody PushTemplateSaveRequest request) {
        return Map.of("pushTemplateUuid", pushTemplateService.save(request).getPushTemplateUuid());
    }

    @DeleteMapping("/templates/{pushTemplateUuid}")
    @ResponseBody
    public ResponseEntity<Void> deleteTemplate(@PathVariable UUID pushTemplateUuid) {
        pushTemplateService.delete(pushTemplateUuid);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/settings")
    @ResponseBody
    public ResponseEntity<Void> updateSettings(@RequestBody NotificationSettingsRequest request) {
        if (request.retentionDays() == null) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "retentionDays");
        }
        notificationSettingService.updateSettings(new NotificationSettingService.NotificationSettings(
                request.retentionDays(), Boolean.TRUE.equals(request.isReportResolvedEnabled())));
        return ResponseEntity.ok().build();
    }
}
