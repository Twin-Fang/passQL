package com.passql.web.controller.admin;

import com.passql.application.entitlement.EntitlementAdminService;
import com.passql.application.entitlement.EntitlementPurchaseRevoker.RecalculationKind;
import com.passql.application.notification.MemberNotificationService;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.MemberRole;
import com.passql.member.constant.MemberStatus;
import com.passql.member.dto.MemberSearchCondition;
import com.passql.member.dto.MemberSuspendRequest;
import com.passql.member.service.MemberAdminService;
import com.passql.member.service.MemberService;
import com.passql.member.service.PushNotificationService;
import com.passql.submission.service.SubmissionService;
import com.passql.web.support.AdminFlash;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import com.passql.web.support.AdminPageRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.util.UUID;

@Controller
@RequestMapping("/admin/members")
@RequiredArgsConstructor
public class AdminMemberController {

    private final MemberAdminService memberAdminService;
    private final SubmissionService submissionService;
    private final MemberService memberService;
    private final MemberNotificationService memberNotificationService;
    private final PushNotificationService pushNotificationService;
    private final EntitlementAdminService entitlementAdminService;

    @GetMapping
    @AdminPage(menu = AdminMenu.MEMBERS)
    public String list(MemberSearchCondition condition, Model model,
                       @RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = AdminPageRequest.DEFAULT_PAGE_SIZE) int size) {
        Pageable pageable = AdminPageRequest.newestFirst(page, size);

        model.addAttribute("members", memberAdminService.searchMembers(condition, pageable));
        model.addAttribute("condition", condition);
        model.addAttribute("statuses", MemberStatus.values());
        model.addAttribute("roles", MemberRole.values());
        return "admin/members/list";
    }

    @GetMapping("/{memberUuid}")
    @AdminPage(menu = AdminMenu.MEMBERS, title = "회원 상세")
    public String detail(@PathVariable UUID memberUuid, Model model) {
        model.addAttribute("member", memberAdminService.getMemberDetail(memberUuid));
        model.addAttribute("submissions", submissionService.getSubmissionsByMember(memberUuid));
        model.addAttribute("notifications", memberNotificationService.findRecentNotificationsOfMember(memberUuid));
        model.addAttribute("pushDevices", pushNotificationService.summarizeDevices(memberUuid));
        model.addAttribute("entitlement", entitlementAdminService.getEntitlementView(memberUuid));
        return "admin/members/detail";
    }

    @PostMapping("/{memberUuid}/suspend")
    @ResponseBody
    public ResponseEntity<Void> suspend(@PathVariable UUID memberUuid,
                                        @RequestBody MemberSuspendRequest request) {
        memberAdminService.suspendMember(memberUuid, request.getReason(), request.getSuspendUntil());
        return ResponseEntity.ok().build();
    }

    /** 관리자 탈퇴 처리 (#479): 개인정보 익명화·로그인 차단, 풀이 기록 보존 */
    @PostMapping("/{memberUuid}/withdraw")
    @ResponseBody
    public ResponseEntity<Void> withdraw(@PathVariable UUID memberUuid) {
        memberService.withdrawByAdmin(memberUuid);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{memberUuid}/unsuspend")
    @ResponseBody
    public ResponseEntity<Void> unsuspend(@PathVariable UUID memberUuid) {
        memberAdminService.unsuspendMember(memberUuid);
        return ResponseEntity.ok().build();
    }

    /** 프로 수동 부여: 선택 날짜 23:59:59 까지, 실패 시 화면에 오류 문구 */
    @PostMapping("/{memberUuid}/entitlement/grant")
    public String grantPro(@PathVariable UUID memberUuid,
                           @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate expiresDate,
                           RedirectAttributes redirectAttributes) {
        try {
            entitlementAdminService.grantPro(memberUuid, expiresDate);
            redirectAttributes.addFlashAttribute(AdminFlash.TOAST_MESSAGE, "프로를 부여했습니다.");
        } catch (CustomException exception) {
            String errorMessage = exception.getErrorCode() == ErrorCode.INVALID_INPUT_VALUE
                ? "만료일은 오늘 이후 날짜여야 합니다." : exception.getErrorCode().getMessage();
            redirectAttributes.addFlashAttribute(AdminFlash.ENTITLEMENT_ERROR_MESSAGE, errorMessage);
        }
        return "redirect:/admin/members/" + memberUuid;
    }

    /** 구매 1건 회수: REVOKED + 등급 재계산, 실패 시 화면에 오류 문구 */
    @PostMapping("/{memberUuid}/entitlement/purchases/{entitlementPurchaseUuid}/revoke")
    public String revokePurchase(@PathVariable UUID memberUuid, @PathVariable UUID entitlementPurchaseUuid,
                                 RedirectAttributes redirectAttributes) {
        try {
            RecalculationKind recalculationKind = entitlementAdminService.revokePurchase(memberUuid, entitlementPurchaseUuid);
            // 관리자 부여 등급이면 구매만 회수, 이용권 만료일은 그대로
            String toastMessage = recalculationKind == RecalculationKind.ADMIN_GRANT_KEPT
                ? "구매를 회수했습니다. 관리자 부여 이용권은 그대로입니다." : "구매를 회수했습니다.";
            redirectAttributes.addFlashAttribute(AdminFlash.TOAST_MESSAGE, toastMessage);
        } catch (CustomException exception) {
            // 거절 사유별 문구: 이미 회수, 다른 회원·없는 구매, 그 외는 공통 오류 처리
            String errorMessage = switch (exception.getErrorCode()) {
                case INVALID_REQUEST -> "이미 회수된 구매입니다.";
                case ACCESS_DENIED, RESOURCE_NOT_FOUND -> "이 회원의 구매가 아닙니다.";
                default -> throw exception;
            };
            redirectAttributes.addFlashAttribute(AdminFlash.ENTITLEMENT_ERROR_MESSAGE, errorMessage);
        }
        return "redirect:/admin/members/" + memberUuid;
    }

    /** 프로 회수: 등급을 무료로 되돌림 */
    @PostMapping("/{memberUuid}/entitlement/revoke")
    public String revokePro(@PathVariable UUID memberUuid, RedirectAttributes redirectAttributes) {
        entitlementAdminService.revokePro(memberUuid);
        redirectAttributes.addFlashAttribute(AdminFlash.TOAST_MESSAGE, "프로를 회수했습니다.");
        return "redirect:/admin/members/" + memberUuid;
    }
}
