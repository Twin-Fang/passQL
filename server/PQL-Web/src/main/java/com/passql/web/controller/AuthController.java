package com.passql.web.controller;

import com.passql.member.auth.application.AuthorizationCodeLoginService;
import com.passql.member.auth.application.dto.result.SocialLoginClientConfig;
import com.passql.member.auth.presentation.dto.request.AuthorizationCodeLoginRequest;
import java.util.List;
import com.passql.member.auth.application.AuthService;
import com.passql.member.auth.application.dto.result.LoginResult;
import com.passql.member.auth.domain.Tokens;
import com.passql.member.auth.presentation.dto.request.LoginRequest;
import com.passql.member.auth.presentation.dto.request.LogoutRequest;
import com.passql.member.auth.presentation.dto.request.ReissueRequest;
import com.passql.member.auth.presentation.dto.response.LoginResponse;
import com.passql.member.auth.presentation.dto.response.ReissueResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final AuthorizationCodeLoginService authorizationCodeLoginService;

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody @Valid LoginRequest request) {
        LoginResult result = authService.login(request.toCommand());
        LoginResponse response = LoginResponse.from(result);
        return result.isNewMember()
                ? ResponseEntity.status(HttpStatus.CREATED).body(response)
                : ResponseEntity.ok(response);
    }

    /** 인가 코드 로그인 (카카오·네이버·GitHub, #509) */
    @PostMapping("/login/code")
    public ResponseEntity<LoginResponse> loginWithAuthorizationCode(@RequestBody @Valid AuthorizationCodeLoginRequest request) {
        LoginResult result = authorizationCodeLoginService.login(
                request.authProvider(), request.code(), request.redirectUri(), request.state());
        LoginResponse response = LoginResponse.from(result);
        return result.isNewMember()
                ? ResponseEntity.status(HttpStatus.CREATED).body(response)
                : ResponseEntity.ok(response);
    }

    /** 인가 코드 로그인 공개 설정 (제공자별 사용 여부, 공개 client ID) */
    @GetMapping("/social-config")
    public ResponseEntity<List<SocialLoginClientConfig>> getSocialLoginConfig() {
        return ResponseEntity.ok(authorizationCodeLoginService.getClientConfigs());
    }

    @PostMapping("/reissue")
    public ResponseEntity<ReissueResponse> reissue(@RequestBody @Valid ReissueRequest request) {
        Tokens tokens = authService.reissueTokens(request.refreshToken());
        return ResponseEntity.ok(ReissueResponse.from(tokens));
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(@RequestBody @Valid LogoutRequest request) {
        authService.logout(request.refreshToken());
        return ResponseEntity.noContent().build();
    }
}
