package com.passql.web.support;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

/**
 * @AdminPage 핸들러 뷰 렌더 직전: currentMenu·pageTitle 모델 주입
 * 리다이렉트·JSON 응답은 건너뜀, 컨트롤러가 직접 넣은 값은 유지
 */
public class AdminPageModelInterceptor implements HandlerInterceptor {

    // layout.html 이 읽는 모델 속성 이름
    public static final String CURRENT_MENU_ATTRIBUTE = "currentMenu";
    public static final String PAGE_TITLE_ATTRIBUTE = "pageTitle";
    private static final String REDIRECT_VIEW_PREFIX = "redirect:";

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response,
                           Object handler, ModelAndView modelAndView) {
        if (modelAndView == null || !(handler instanceof HandlerMethod handlerMethod)) {
            return;
        }
        AdminPage adminPage = handlerMethod.getMethodAnnotation(AdminPage.class);
        if (adminPage == null || isRedirectView(modelAndView)) {
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
