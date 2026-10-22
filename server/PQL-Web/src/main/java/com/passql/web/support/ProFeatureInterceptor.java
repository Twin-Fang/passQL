package com.passql.web.support;

import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.auth.presentation.security.LoginMember;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * 프로 기능 전체 잠금 단일 지점: @RequiresProFeature 엔드포인트 > FeatureAccessPolicy.requireFeature
 * 어노테이션 없는 엔드포인트는 정책을 부르지 않음
 */
@RequiredArgsConstructor
public class ProFeatureInterceptor implements HandlerInterceptor {

    private final FeatureAccessPolicy featureAccessPolicy;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        if (!(handler instanceof HandlerMethod handlerMethod)) {
            return true;
        }
        RequiresProFeature requiresProFeature = handlerMethod.getMethodAnnotation(RequiresProFeature.class);
        if (requiresProFeature == null) {
            return true;
        }

        // 로그인 회원 없음 (공개 엔드포인트): 결제 켜짐일 때만 무료 취급
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof LoginMember loginMember)) {
            if (featureAccessPolicy.isBillingEnabled()) {
                throw new CustomException(ErrorCode.PRO_REQUIRED);
            }
            return true;
        }

        featureAccessPolicy.requireFeature(loginMember.memberUuid(), requiresProFeature.value());
        return true;
    }
}
