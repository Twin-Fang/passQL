package com.passql.member.auth.presentation.dto.request;

import com.passql.member.constant.AuthProvider;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * 인가 코드 로그인 요청 (#509): 제공자, 인가 코드, 인가 때 쓴 redirect URI, (네이버) state
 */
public record AuthorizationCodeLoginRequest(
        @NotNull(message = "소셜 플랫폼 정보는 필수입니다.")
        AuthProvider authProvider,
        @NotBlank(message = "인가 코드는 필수입니다.")
        @Size(max = 512)
        String code,
        @NotBlank(message = "redirect URI 는 필수입니다.")
        @Size(max = 512)
        String redirectUri,
        @Schema(nullable = true)
        @Size(max = 128)
        String state
) {}
