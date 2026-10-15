package com.passql.web.controller.admin;

import com.passql.member.constant.PushAudience;
import com.passql.member.constant.PushLinkTarget;
import com.passql.member.dto.PushSendRequest;
import com.passql.member.dto.PushSendResult;
import com.passql.member.service.PushNotificationService;
import com.passql.web.support.AdminPageRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.security.Principal;

/** 관리자 푸시 발송 화면: 발송 폼, 발송, 발송 이력 */
@Controller
@RequestMapping("/admin/push")
@RequiredArgsConstructor
public class AdminPushController {

    private final PushNotificationService pushNotificationService;

    @GetMapping
    public String page(Model model,
                       @RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = AdminPageRequest.DEFAULT_PAGE_SIZE) int size) {
        // 정렬은 findAllByOrderBySentAtDesc 메서드명에서 처리
        model.addAttribute("histories", pushNotificationService.getSendHistories(AdminPageRequest.of(page, size, Sort.unsorted())));
        model.addAttribute("pushEnabledDeviceCount", pushNotificationService.countPushEnabledDevices());
        model.addAttribute("audiences", PushAudience.values());
        model.addAttribute("linkTargets", PushLinkTarget.values());
        model.addAttribute("pageTitle", "푸시 발송");
        model.addAttribute("currentMenu", "push");
        return "admin/push";
    }

    @PostMapping("/send")
    @ResponseBody
    public PushSendResult send(@Valid @RequestBody PushSendRequest request, Principal principal) {
        return pushNotificationService.send(request, principal.getName());
    }
}
