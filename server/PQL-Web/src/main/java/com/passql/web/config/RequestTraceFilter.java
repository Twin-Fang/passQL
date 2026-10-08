package com.passql.web.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.passql.common.exception.GlobalExceptionHandler;
import com.passql.meta.service.ServerErrorLogService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.UUID;
import java.util.regex.Pattern;

/**
 * 요청 추적 (#436).
 *
 * <p>요청마다 ID를 MDC(rid)에 넣어 이 요청에서 나온 모든 로그 줄에 붙이고, 응답 헤더 X-Request-Id 로 돌려준다.
 * 사용자 제보에 이 값만 있으면 grep 한 번으로 해당 요청 로그를 모은다.
 * 인증 회원 ID(mid)는 JwtAuthenticationFilter 가 채운다. 요청 종료 시 한 줄 요약을 남긴다
 * — suh-logger 블록은 여러 줄이라 동시 요청끼리 섞이면 상태·처리 시간을 짝지을 수 없다.
 *
 * <p>suh-logger 필터보다 먼저 돌아야 그 로그에도 rid 가 붙으므로 가장 높은 우선순위로 둔다.
 * 5xx·미처리 예외는 관리자 모니터링용으로 DB 에도 남긴다 (#440).
 */
@Slf4j
@Component
@RequiredArgsConstructor
@Order(Ordered.HIGHEST_PRECEDENCE)
public class RequestTraceFilter extends OncePerRequestFilter {

    public static final String HEADER = "X-Request-Id";
    public static final String MDC_REQUEST_ID = "rid";
    public static final String MDC_MEMBER_ID = "mid";

    // 외부에서 온 값은 로그 줄에 그대로 들어가므로 짧은 영숫자만 받는다 (로그 위조 방지)
    private static final Pattern SAFE_ID = Pattern.compile("[A-Za-z0-9-]{8,64}");

    private final ServerErrorLogService serverErrorLogService;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String incoming = request.getHeader(HEADER);
        String requestId = incoming != null && SAFE_ID.matcher(incoming).matches()
                ? incoming
                : UUID.randomUUID().toString().substring(0, 8);
        MDC.put(MDC_REQUEST_ID, requestId);
        response.setHeader(HEADER, requestId);

        long start = System.nanoTime();
        Throwable failure = null;
        try {
            filterChain.doFilter(request, response);
        } catch (IOException | ServletException | RuntimeException | Error e) {
            // 핸들러가 처리하지 못한 예외 — 아직 응답 상태가 200 일 수 있어 직접 500 으로 본다
            failure = e;
            throw e;
        } finally {
            String uri = request.getRequestURI();
            if (shouldSummarize(uri)) {
                long ms = (System.nanoTime() - start) / 1_000_000;
                int status = failure != null ? 500 : response.getStatus();
                // 5xx 만 WARN — 레벨로 장애 요청을 바로 걸러낼 수 있게 한다
                if (status >= 500) {
                    log.warn("[req] {} {} -> {} ({}ms)", request.getMethod(), uri, status, ms);
                    serverErrorLogService.record(requestId, MDC.get(MDC_MEMBER_ID), request.getMethod(),
                            uri, status, describe(failure, request));
                } else {
                    log.info("[req] {} {} -> {} ({}ms)", request.getMethod(), uri, status, ms);
                }
            }
            // 스레드 풀 재사용 시 다음 요청에 이전 ID 가 남지 않게 반드시 비운다
            MDC.remove(MDC_REQUEST_ID);
            MDC.remove(MDC_MEMBER_ID);
        }
    }

    /** 오류 원인 요약: 전파된 예외 → 예외 핸들러가 남긴 요약 → 없음 순. 스택은 로그 파일에서 requestId 로 찾는다. */
    static String describe(Throwable failure, HttpServletRequest request) {
        if (failure != null) {
            Throwable root = failure;
            while (root.getCause() != null && root.getCause() != root) root = root.getCause();
            return root.getClass().getName() + ": " + root.getMessage();
        }
        Object detail = request.getAttribute(GlobalExceptionHandler.ERROR_DETAIL_ATTR);
        return detail != null ? detail.toString() : null;
    }

    /** API·관리자 화면만 요약한다. 헬스체크(5초 간격)·정적 파일(/js, /images 등)은 노이즈라 제외. */
    static boolean shouldSummarize(String uri) {
        return uri != null && (uri.startsWith("/api/") || uri.startsWith("/admin"));
    }
}
