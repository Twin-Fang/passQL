package com.passql.web.config;

import com.passql.member.auth.presentation.security.LoginMemberArgumentResolver;
import com.passql.web.support.AdminPageModelInterceptor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.List;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addArgumentResolvers(List<HandlerMethodArgumentResolver> resolvers) {
        resolvers.add(new LoginMemberArgumentResolver());
    }

    // 관리자 화면 메뉴·제목 공통 주입 (@AdminPage)
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new AdminPageModelInterceptor()).addPathPatterns("/admin/**");
    }
}
