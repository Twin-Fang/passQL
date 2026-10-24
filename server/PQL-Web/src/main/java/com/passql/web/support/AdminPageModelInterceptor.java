package com.passql.web.support;

import com.passql.application.service.AdminSidebarBadgeService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

/**
 * 관리자 화면 뷰 렌더 직전 공통 모델: 로그인 관리자·변경 권한·사이드바 메뉴·미처리 뱃지(모든 화면), currentMenu·pageTitle(@AdminPage)
 * 리다이렉트·JSON 응답은 건너뜀, 컨트롤러가 직접 넣은 값은 유지
 */
@RequiredArgsConstructor
public class AdminPageModelInterceptor implements HandlerInterceptor {

    // layout.html 이 읽는 모델 속성 이름
    public static final String CURRENT_MENU_ATTRIBUTE = "currentMenu";
    public static final String PAGE_TITLE_ATTRIBUTE = "pageTitle";
    public static final String CURRENT_ADMIN_USERNAME_ATTRIBUTE = "currentAdminUsername";
    // true: ADMIN (변경·계정 관리 가능), false: VIEWER 조회 전용
    public static final String CAN_WRITE_ADMIN_ATTRIBUTE = "canWriteAdmin";
    // Spring Security 역할 이름 (AdminRole.ADMIN)
    private static final String ADMIN_SECURITY_ROLE = "ADMIN";
    // 사이드바 그룹·항목 (AdminSidebar), 메뉴 코드 > 미처리 건수 (AdminSidebarBadgeService)
    public static final String SIDEBAR_GROUPS_ATTRIBUTE = "sidebarGroups";
    public static final String SIDEBAR_BADGE_COUNTS_ATTRIBUTE = "sidebarBadgeCounts";
    private static final String REDIRECT_VIEW_PREFIX = "redirect:";

    private final AdminSidebarBadgeService adminSidebarBadgeService;

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response,
                           Object handler, ModelAndView modelAndView) {
        if (modelAndView == null || isRedirectView(modelAndView)) {
            return;
        }
        if (request.getUserPrincipal() != null) {
            modelAndView.getModel().putIfAbsent(CURRENT_ADMIN_USERNAME_ATTRIBUTE, request.getUserPrincipal().getName());
            modelAndView.getModel().putIfAbsent(CAN_WRITE_ADMIN_ATTRIBUTE, request.isUserInRole(ADMIN_SECURITY_ROLE));
            // 로그인 화면은 principal 이 없어 사이드바 모델 불필요
            modelAndView.getModel().putIfAbsent(SIDEBAR_GROUPS_ATTRIBUTE, AdminSidebar.GROUPS);
            modelAndView.getModel().putIfAbsent(SIDEBAR_BADGE_COUNTS_ATTRIBUTE, adminSidebarBadgeService.countPendingByMenuCode());
        }
        if (!(handler instanceof HandlerMethod handlerMethod)) {
            return;
        }
        AdminPage adminPage = handlerMethod.getMethodAnnotation(AdminPage.class);
        if (adminPage == null) {
            return;
        }
        String pageTitle = adminPage.title().isEmpty() ? adminPage.menu().getDefaultTitle() : adminPage.title();
        modelAndView.getModel().putIfAbsent(CURRENT_MENU_ATTRIBUTE, adminPage.menu().getCode());
        modelAndView.getModel().putIfAbsent(PAGE_TITLE_ATTRIBUTE, pageTitle);
    }

    private boolean isRedirectView(ModelAndView modelAndView) {
        String viewName = modelAndView.getViewName();
        return viewName != null && viewName.startsWith(REDIRECT_VIEW_PREFIX);
    }
}
