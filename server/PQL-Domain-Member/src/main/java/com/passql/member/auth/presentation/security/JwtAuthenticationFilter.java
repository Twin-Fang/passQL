package com.passql.member.auth.presentation.security;

import com.passql.member.auth.infrastructure.jwt.JwtTokenProvider;
import com.passql.member.constant.MemberRole;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

@Slf4j
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final String AUTHORIZATION_HEADER = "Authorization";
    private static final String BEARER_PREFIX = "Bearer ";

    // RequestTraceFilter(PQL-Web)가 요청 종료 시 지운다 — 모듈 의존 방향 때문에 키만 같은 문자열로 맞춘다 (#436)
    private static final String MDC_MEMBER_ID = "mid";

    private final JwtTokenProvider jwtTokenProvider;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String token = extractToken(request);
        if (StringUtils.hasText(token)) {
            try {
                UUID memberUuid = jwtTokenProvider.getMemberUuidFromAccessToken(token);
                MemberRole role = jwtTokenProvider.getRoleFromAccessToken(token);
                LoginMember loginMember = new LoginMember(memberUuid, role);

                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(
                                loginMember,
                                null,
                                List.of(new SimpleGrantedAuthority(role.getAuthority()))
                        );
                SecurityContextHolder.getContext().setAuthentication(authentication);
                // 이후 로그 줄에 회원을 붙인다. 전체 UUID 대신 앞 8자리 — 추적엔 충분하고 로그가 짧아진다
                MDC.put(MDC_MEMBER_ID, memberUuid.toString().substring(0, 8));
            } catch (Exception e) {
                // 유효하지 않은 토큰 — SecurityContext 비우고 다음 필터로 진행
                // 인증 필요 경로는 SecurityConfig에서 401 처리
                SecurityContextHolder.clearContext();
                log.debug("[JwtFilter] 토큰 검증 실패: {}", e.getMessage());
            }
        }
        filterChain.doFilter(request, response);
    }

    private String extractToken(HttpServletRequest request) {
        String header = request.getHeader(AUTHORIZATION_HEADER);
        if (StringUtils.hasText(header) && header.startsWith(BEARER_PREFIX)) {
            return header.substring(BEARER_PREFIX.length());
        }
        return null;
    }
}
