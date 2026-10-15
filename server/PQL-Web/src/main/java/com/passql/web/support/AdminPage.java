package com.passql.web.support;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 관리자 화면 핸들러 표시: 메뉴 > currentMenu·pageTitle 모델 자동 주입 (AdminPageModelInterceptor)
 * title 비우면 메뉴 기본 제목
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface AdminPage {

    AdminMenu menu();

    String title() default "";
}
