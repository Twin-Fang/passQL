package com.passql.web.config;

import com.passql.common.util.AdminRequestContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.AuditorAware;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

import java.util.Optional;

/**
 * JPA auditor (created_by·updated_by): 관리자 세션 요청 > 관리자 아이디, 그 외(회원 API·스케줄러) > system (#469)
 */
@Configuration
@EnableJpaAuditing(auditorAwareRef = "auditorProvider")
public class JpaConfig {

    @Bean
    public AuditorAware<String> auditorProvider() {
        return () -> Optional.of(AdminRequestContext.findAdminUsernameOrSystem());
    }
}
