package com.passql.web.support;

import com.passql.application.entitlement.ProFeature;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 기능 전체 잠금 표시: 붙은 엔드포인트는 무료 회원에게 403 PRO_REQUIRED
 * 판정은 ProFeatureInterceptor 한 곳에서 처리
 */
@Documented
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RequiresProFeature {

    // 잠글 프로 기능
    ProFeature value();
}
