package com.passql.member.auth.application.dto.result;

import com.passql.member.constant.AuthProvider;
import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 인가 코드 로그인 제공자 공개 설정 1개 (#509): 사용 여부 + 공개 client ID (secret 은 절대 포함하지 않음)
 */
public record SocialLoginClientConfig(
        AuthProvider authProvider,
        boolean isEnabled,
        @Schema(nullable = true) String clientId
) {}
