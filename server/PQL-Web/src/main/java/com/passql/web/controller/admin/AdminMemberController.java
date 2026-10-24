package com.passql.web.controller.admin;

import com.passql.application.entitlement.EntitlementAdminService;
import com.passql.application.entitlement.EntitlementPurchaseRevoker.RevocationResult;
import com.passql.application.entitlement.EntitlementTimelineService;

import com.passql.application.community.CommunityAdminService;
import com.passql.application.member.MemberAdminOperationService;
import com.passql.application.notification.MemberNotificationService;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.MemberListSort;
import com.passql.member.constant.MemberPlanFilter;
import com.passql.member.constant.MemberRole;
import com.passql.member.constant.MemberStatus;
import com.passql.member.constant.SuspendReasonCategory;
import com.passql.member.dto.MemberAdminDetailResponse;
import com.passql.member.dto.MemberAdminMemoRequest;
import com.passql.member.dto.MemberBulkPushRequest;
import com.passql.member.dto.MemberBulkResultResponse;
import com.passql.member.dto.MemberBulkSuspendRequest;
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
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.security.Principal;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@Controller
@RequestMapping("/admin/members")
@RequiredArgsConstructor
public class AdminMemberController {

    // 프로 부여·회수 토스트 날짜 (회원 상세 카드 만료일의 날짜 부분과 같은 표기)
    private static final DateTimeFormatter TOAST_DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    // 회원 상세 탭: 기본 탭 이름 (제출 이력)
    private static final String TAB_SUBMISSION = "submission";
    // 회원 상세 제출·알림 탭 한 페이지 건수
    private static final int TAB_PAGE_SIZE = 20;

    private final MemberAdminService memberAdminService;
    private final SubmissionService submissionService;
    private final MemberService memberService;
    private final MemberNotificationService memberNotificationService;
    private final PushNotificationService pushNotificationService;
    private final EntitlementAdminService entitlementAdminService;
    private final EntitlementTimelineService entitlementTimelineService;

    private final CommunityAdminService communityAdminService;
    private final MemberAdminOperationService memberAdminOperationService;

    @GetMapping
    @AdminPage(menu = AdminMenu.MEMBERS)
    public String list(MemberSearchCondition condition, Model model,
                       @RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = AdminPageRequest.DEFAULT_PAGE_SIZE) int size) {
        Pageable pageable = AdminPageRequest.newestFirst(page, size);

        model.addAttribute("members", memberAdminService.searchMembers(condition, pageable));
        model.addAttribute("summary", memberAdminService.summarizeMembers(Boolean.TRUE.equals(condition.getIncludeTest())));
        model.addAttribute("condition", condition);
        model.addAttribute("statuses", MemberStatus.values());
        model.addAttribute("roles", MemberRole.values());
        model.addAttribute("sorts", MemberListSort.values());
        model.addAttribute("planFilters", MemberPlanFilter.values());
        model.addAttribute("reasonCategories", SuspendReasonCategory.values());
        return "admin/members/list";
    }

    /** 회원 상세: 탭(제출·알림)은 서버 페이지네이션, 커뮤니티 활동은 최근 30건 */
    @GetMapping("/{memberUuid}")
    @AdminPage(menu = AdminMenu.MEMBERS, title = "회원 상세")
    public String detail(@PathVariable UUID memberUuid, Model model,
                         @RequestParam(defaultValue = TAB_SUBMISSION) String tab,
                         @RequestParam(defaultValue = "0") int submissionPage,
                         @RequestParam(defaultValue = "0") int notificationPage) {
        MemberAdminDetailResponse member = memberAdminService.getMemberDetail(memberUuid);
        model.addAttribute("member", member);
        model.addAttribute("activeTab", tab);
        model.addAttribute("submissions", submissionService.getSubmissionPageByMember(memberUuid,
            AdminPageRequest.of(submissionPage, TAB_PAGE_SIZE, Sort.unsorted())));
        model.addAttribute("totalSubmissionCount", submissionService.countSubmissionsByMember(memberUuid));
        model.addAttribute("correctSubmissionCount", submissionService.countCorrectSubmissionsByMember(memberUuid));
        model.addAttribute("notifications", memberNotificationService.findNotificationPageOfMember(memberUuid,
            AdminPageRequest.of(notificationPage, TAB_PAGE_SIZE, Sort.unsorted())));
        model.addAttribute("pushDevices", pushNotificationService.summarizeDevices(memberUuid));
        model.addAttribute("entitlement", entitlementAdminService.getEntitlementView(memberUuid));
        model.addAttribute("entitlementTimeline", entitlementTimelineService.getTimeline(memberUuid));

        model.addAttribute("communityActivity", communityAdminService.getMemberActivity(memberUuid, member.nickname()));
        model.addAttribute("reasonCategories", SuspendReasonCategory.values());
        return "admin/members/detail";
    }

    @PostMapping("/{memberUuid}/suspend")
    @ResponseBody
    public ResponseEntity<Void> suspend(@PathVariable UUID memberUuid,
                                        @RequestBody MemberSuspendRequest request) {
        memberAdminService.suspendMember(memberUuid, SuspendReasonCategory.fromRequestValueOrNull(request.getReasonCategory()),
            request.getReason(), request.getSuspendUntil());
        return ResponseEntity.ok().build();
    }

    /** 관리자 메모 저장 (공백만이면 삭제, 앱 미노출) */
    @PutMapping("/{memberUuid}/memo")
    @ResponseBody
    public ResponseEntity<Void> updateMemo(@PathVariable UUID memberUuid,
                                           @Valid @RequestBody MemberAdminMemoRequest request) {
        memberAdminService.updateAdminMemo(memberUuid, request.adminMemo());
        return ResponseEntity.ok().build();
    }

    /** 회원 일괄 제재 (최대 100명, 관리자·탈퇴 회원은 건너뜀) */
    @PostMapping("/bulk-suspend")
    @ResponseBody
    public MemberBulkResultResponse bulkSuspend(@Valid @RequestBody MemberBulkSuspendRequest request) {
        return memberAdminOperationService.suspendMembers(request);
    }

    /** 회원 푸시: 1명(회원 상세)부터 최대 100명(목록 일괄), 푸시 + 알림함 */
    @PostMapping("/bulk-push")
    @ResponseBody
    public MemberBulkResultResponse bulkPush(@Valid @RequestBody MemberBulkPushRequest request, Principal principal) {
        return memberAdminOperationService.sendPushToMembers(request, principal.getName());
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

    /** 프로 수동 부여: 선택 날짜 23:59:59 까지, 사유 필수, 실패 시 화면에 오류 문구 */
    @PostMapping("/{memberUuid}/entitlement/grant")
    public String grantPro(@PathVariable UUID memberUuid,
                           @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate expiresDate,
                           @RequestParam(required = false) String reason,
                           RedirectAttributes redirectAttributes) {
        if (!EntitlementAdminService.isValidReason(reason)) {
            return redirectWithReasonError(memberUuid, redirectAttributes);
        }
        try {
            boolean isShortened = entitlementAdminService.grantPro(memberUuid, expiresDate, reason);
            String formattedExpiresDate = expiresDate.format(TOAST_DATE_FORMATTER);
            String toastMessage = isShortened
                ? "프로 만료일을 줄였습니다. (" + formattedExpiresDate + "까지)"
                : "프로를 " + formattedExpiresDate + "까지 부여했습니다.";
            redirectAttributes.addFlashAttribute(AdminFlash.TOAST_MESSAGE, toastMessage);
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
                                 @RequestParam(required = false) String reason,
                                 RedirectAttributes redirectAttributes) {
        if (!EntitlementAdminService.isValidReason(reason)) {
            return redirectWithReasonError(memberUuid, redirectAttributes);
        }
        try {
            RevocationResult revocationResult = entitlementAdminService.revokePurchase(memberUuid, entitlementPurchaseUuid, reason);
            redirectAttributes.addFlashAttribute(AdminFlash.TOAST_MESSAGE, toRevokePurchaseToastMessage(revocationResult));
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
    public String revokePro(@PathVariable UUID memberUuid, @RequestParam(required = false) String reason,
                            RedirectAttributes redirectAttributes) {
        if (!EntitlementAdminService.isValidReason(reason)) {
            return redirectWithReasonError(memberUuid, redirectAttributes);
        }
        entitlementAdminService.revokePro(memberUuid, reason);
        redirectAttributes.addFlashAttribute(AdminFlash.TOAST_MESSAGE, "프로를 회수했습니다.");
        return "redirect:/admin/members/" + memberUuid;
    }

    /** 사유 없음·너무 김 > 회원 상세 등급 카드 오류 문구 */
    private String redirectWithReasonError(UUID memberUuid, RedirectAttributes redirectAttributes) {
        redirectAttributes.addFlashAttribute(AdminFlash.ENTITLEMENT_ERROR_MESSAGE,
            "사유를 입력해 주세요. (최대 " + EntitlementAdminService.MAX_REASON_LENGTH + "자)");
        return "redirect:/admin/members/" + memberUuid;
    }

    /** 구매 회수 결과 > 토스트 (관리자 부여 유지, 무료 전환, 만료일 변경, 등급 행 없음) */
    private String toRevokePurchaseToastMessage(RevocationResult revocationResult) {
        return switch (revocationResult.kind()) {
            // 관리자 회수로 이미 무료(만료일 없음)면 유지할 이용권이 없음
            case ADMIN_GRANT_KEPT -> revocationResult.afterExpiresAt() == null
                ? "구매를 회수했습니다."
                : "구매를 회수했습니다. 관리자 부여 이용권은 그대로입니다.";
            case RECALCULATED -> revocationResult.afterExpiresAt() == null
                ? "구매를 회수했습니다. 무료로 바뀌었습니다."
                : "구매를 회수했습니다. 만료일이 바뀌었습니다. (" + revocationResult.afterExpiresAt().format(TOAST_DATE_FORMATTER) + "까지)";
            case NO_ENTITLEMENT -> "구매를 회수했습니다.";
        };
    }
}
