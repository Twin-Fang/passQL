package com.passql.web.config;

import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.member.auth.presentation.security.LoginMemberArgumentResolver;
import com.passql.member.service.MemberActivityRecorder;
import com.passql.web.support.AdminPageModelInterceptor;
import com.passql.web.support.MemberActivityInterceptor;
import com.passql.web.support.ProFeatureInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.List;

@Configuration
@RequiredArgsConstructor
public class WebMvcConfig implements WebMvcConfigurer {

    private final MemberActivityRecorder memberActivityRecorder;
    private final FeatureAccessPolicy featureAccessPolicy;

    @Override
    public void addArgumentResolvers(List<HandlerMethodArgumentResolver> resolvers) {
        resolvers.add(new LoginMemberArgumentResolver());
    }

    // 관리자 화면 메뉴·제목 공통 주입 (@AdminPage), 회원 API 활동 기록 (#557), 프로 기능 잠금 (#576)
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new AdminPageModelInterceptor()).addPathPatterns("/admin/**");
        registry.addInterceptor(new MemberActivityInterceptor(memberActivityRecorder)).addPathPatterns("/api/**");
        registry.addInterceptor(new ProFeatureInterceptor(featureAccessPolicy)).addPathPatterns("/api/**");
    }
}
