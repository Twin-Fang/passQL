package com.passql.web.controller.admin;

import com.passql.application.notification.MemberNotificationService;
import com.passql.application.notification.NotificationSettingService;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.NotificationDeliveryMode;
import com.passql.member.constant.PushAudience;
import com.passql.member.constant.PushLinkTarget;
import com.passql.member.dto.PushSendAcceptedResponse;
import com.passql.member.dto.PushSendRequest;
import com.passql.member.service.PushNotificationService;
import com.passql.web.dto.notification.NotificationSettingsRequest;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import com.passql.web.support.AdminPageRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.security.Principal;
import java.util.Map;
import java.util.UUID;

/** 관리자 알림 발송 화면(탭 3개): 발송, 발송 이력(회수), 알림 설정 */
@Controller
@RequestMapping("/admin/push")
@RequiredArgsConstructor
public class AdminPushController {

    private final PushNotificationService pushNotificationService;
    private final MemberNotificationService memberNotificationService;
    private final NotificationSettingService notificationSettingService;

    @GetMapping
    @AdminPage(menu = AdminMenu.PUSH)
    public String page(Model model,
                       @RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = AdminPageRequest.DEFAULT_PAGE_SIZE) int size) {
        // 정렬은 findAllByOrderBySentAtDesc 메서드명에서 처리
        model.addAttribute("histories", memberNotificationService.getHistoryRows(AdminPageRequest.of(page, size, Sort.unsorted())));
        model.addAttribute("pushEnabledDeviceCount", pushNotificationService.countPushEnabledDevices());
        model.addAttribute("inboxRecipientCount", pushNotificationService.countAllInboxRecipients());
        model.addAttribute("audiences", PushAudience.values());
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

    /** 발송 회수: 받은 회원들의 알림함에서 숨김 (이미 나간 푸시는 되돌릴 수 없음) */
    @PostMapping("/{pushSendHistoryUuid}/retract")
    @ResponseBody
    public Map<String, Integer> retract(@PathVariable UUID pushSendHistoryUuid, Principal principal) {
        int hiddenCount = memberNotificationService.retractAdminMessage(pushSendHistoryUuid, principal.getName());
        return Map.of("hiddenCount", hiddenCount);
    }

    @PutMapping("/settings")
    @ResponseBody
    public ResponseEntity<Void> updateSettings(@RequestBody NotificationSettingsRequest request) {
        if (request.retentionDays() == null) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "retentionDays");
        }
        notificationSettingService.updateSettings(new NotificationSettingService.NotificationSettings(
                request.retentionDays(), Boolean.TRUE.equals(request.isReportResolvedEnabled()),
                Boolean.TRUE.equals(request.isDailySetReminderEnabled())));
        return ResponseEntity.ok().build();
    }
}
