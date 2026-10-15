package com.passql.web.controller.admin;

import com.passql.member.constant.MemberRole;
import com.passql.member.constant.MemberStatus;
import com.passql.member.dto.MemberSearchCondition;
import com.passql.member.dto.MemberSuspendRequest;
import com.passql.member.service.MemberAdminService;
import com.passql.member.service.MemberService;
import com.passql.submission.service.SubmissionService;
import com.passql.web.support.AdminMenu;
import com.passql.web.support.AdminPage;
import com.passql.web.support.AdminPageRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@Controller
@RequestMapping("/admin/members")
@RequiredArgsConstructor
public class AdminMemberController {

    private final MemberAdminService memberAdminService;
    private final SubmissionService submissionService;
    private final MemberService memberService;

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
}
