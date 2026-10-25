package com.passql.web.controller.admin;

import com.passql.application.notification.AutoNotificationService;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.AutoNotificationRuleType;
import com.passql.member.constant.PushLinkTarget;
import com.passql.web.dto.notification.AutoNotificationRuleUpdateRequest;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * 관리자 자동 알림 화면: 재방문 알림 규칙 5종 켜기/끄기·시각·일수·문구·이동 화면, 대상 수 미리보기, 최근 7일 발송 건수
 */
@Controller
@RequestMapping("/admin/auto-notifications")
@RequiredArgsConstructor
public class AdminAutoNotificationController {

    private static final ZoneId SERVER_ZONE = ZoneId.of("Asia/Seoul");

    private final AutoNotificationService autoNotificationService;

    @GetMapping
    @AdminPage(menu = AdminMenu.AUTO_NOTIFICATIONS)
    public String page(Model model) {
        model.addAttribute("ruleViews", autoNotificationService.findRuleViews(LocalDate.now(SERVER_ZONE)));
        // 문제 상세는 문제 UUID 가 필요해 자동 알림 이동 대상에서 제외
        List<PushLinkTarget> linkTargets = Arrays.stream(PushLinkTarget.values())
                .filter(linkTarget -> !linkTarget.isQuestionUuidRequired()).toList();
        model.addAttribute("linkTargets", linkTargets);
        model.addAttribute("recentSentDays", AutoNotificationService.RECENT_SENT_DAYS);
        return "admin/auto-notifications";
    }

    /** 규칙 저장 (쓰기 권한이 없는 조회 전용 계정은 보안 설정에서 403) */
    @PutMapping("/{ruleType}")
    @ResponseBody
    public ResponseEntity<Void> update(@PathVariable String ruleType, @RequestBody AutoNotificationRuleUpdateRequest request) {
        AutoNotificationRuleType type = parseRuleType(ruleType);
        PushLinkTarget linkTarget = request.linkTarget() == null ? null : PushLinkTarget.fromRequestValue(request.linkTarget());
        autoNotificationService.updateRule(type, Boolean.TRUE.equals(request.isEnabled()), request.sendHour(),
                request.thresholdDays(), request.title(), request.body(), linkTarget);
        return ResponseEntity.ok().build();
    }

    /** 지금 기준 대상 수 (발송 없음) */
    @GetMapping("/{ruleType}/target-count")
    @ResponseBody
    public Map<String, Integer> targetCount(@PathVariable String ruleType) {
        return Map.of("memberCount", autoNotificationService.countTargets(parseRuleType(ruleType), LocalDate.now(SERVER_ZONE)));
    }

    private static AutoNotificationRuleType parseRuleType(String ruleType) {
        try {
            return AutoNotificationRuleType.valueOf(ruleType);
        } catch (IllegalArgumentException e) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "ruleType");
        }
    }
}
