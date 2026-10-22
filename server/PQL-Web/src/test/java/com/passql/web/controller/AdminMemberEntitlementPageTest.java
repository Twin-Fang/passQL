package com.passql.web.controller;

import com.passql.application.entitlement.EntitlementAdminService;
import com.passql.member.constant.AuthProvider;
import com.passql.member.constant.PurchaseStore;
import com.passql.member.entity.EntitlementPurchase;
import com.passql.member.entity.Member;
import com.passql.member.repository.EntitlementPurchaseRepository;
import com.passql.member.repository.MemberRepository;
import com.passql.web.PassqlApplication;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.web.csrf.DefaultCsrfToken;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.flash;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * 관리자 회원 상세 등급 화면 (실제 dev DB, 테스트 끝에 롤백): 상세 200 렌더, 부여 후 PRO 표시, 지난 날짜 오류 문구
 */
@SpringBootTest(classes = PassqlApplication.class)
@ActiveProfiles("dev")
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class AdminMemberEntitlementPageTest {

    @Autowired MockMvc mockMvc;
    @Autowired MemberRepository memberRepository;
    @Autowired EntitlementPurchaseRepository entitlementPurchaseRepository;
    @Autowired EntitlementAdminService entitlementAdminService;

    private UUID newMember() {
        String suffix = UUID.randomUUID().toString().substring(0, 8);
        Member member = Member.signUp("test-" + suffix, AuthProvider.GOOGLE, suffix + "@test.local", true, "등급테스트" + suffix);
        return memberRepository.save(member).getMemberUuid();
    }

    @Test
    void 회원_상세가_무료_등급과_부여_폼을_렌더하고_부여하면_프로와_회수_버튼이_보인다() throws Exception {
        UUID memberUuid = newMember();
        // 필터를 끄면 CSRF 속성이 없어 layout 이 읽을 토큰을 직접 넣음
        var csrfToken = new DefaultCsrfToken("X-CSRF-TOKEN", "_csrf", "test-token");

        mockMvc.perform(get("/admin/members/{uuid}", memberUuid).requestAttr("_csrf", csrfToken))
            .andExpect(status().isOk())
            .andExpect(content().string(org.hamcrest.Matchers.containsString("/entitlement/grant")))
            .andExpect(content().string(org.hamcrest.Matchers.not(org.hamcrest.Matchers.containsString("/entitlement/revoke"))));

        entitlementAdminService.grantPro(memberUuid, LocalDate.now().plusDays(30));
        entitlementPurchaseRepository.save(EntitlementPurchase.verified(memberUuid, PurchaseStore.PLAY, "pro_exam_pass",
            "GPA.test-order", "secret-purchase-token", LocalDateTime.now(), LocalDateTime.now().plusDays(30)));

        mockMvc.perform(get("/admin/members/{uuid}", memberUuid).requestAttr("_csrf", csrfToken))
            .andExpect(status().isOk())
            .andExpect(content().string(org.hamcrest.Matchers.containsString("ADMIN_GRANT")))
            .andExpect(content().string(org.hamcrest.Matchers.containsString("/entitlement/revoke")))
            // 구매 이력 행 표시, 구매 토큰은 노출 금지
            .andExpect(content().string(org.hamcrest.Matchers.containsString("GPA.test-order")))
            .andExpect(content().string(org.hamcrest.Matchers.not(org.hamcrest.Matchers.containsString("secret-purchase-token"))));
    }

    @Test
    void 지난_날짜로_부여하면_오류_문구를_플래시로_돌려준다() throws Exception {
        UUID memberUuid = newMember();

        mockMvc.perform(post("/admin/members/{uuid}/entitlement/grant", memberUuid)
                .param("expiresDate", LocalDate.now().minusDays(1).toString()))
            .andExpect(status().is3xxRedirection())
            .andExpect(redirectedUrl("/admin/members/" + memberUuid))
            .andExpect(flash().attribute("entitlementErrorMessage", "만료일은 오늘 이후 날짜여야 합니다."));
    }
}
