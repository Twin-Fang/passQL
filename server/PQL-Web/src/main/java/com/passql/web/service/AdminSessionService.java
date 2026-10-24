package com.passql.web.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.security.core.session.SessionInformation;
import org.springframework.security.core.session.SessionRegistry;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 관리자 로그인 세션: 계정별 활성 세션 수 조회, 계정 세션 강제 종료
 * 종료한 세션은 다음 요청에서 로그인 화면으로 이동 (AdminSecurityConfig expiredUrl)
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminSessionService {

    private final SessionRegistry sessionRegistry;
    private final ApplicationEventPublisher eventPublisher;

    /** 아이디 > 활성(만료 아님) 세션 수 */
    public Map<String, Integer> countActiveSessionsByUsername() {
        Map<String, Integer> activeSessionCountByUsername = new HashMap<>();
        for (Object principal : sessionRegistry.getAllPrincipals()) {
            int activeSessionCount = findActiveSessions(principal).size();
            if (activeSessionCount > 0) {
                activeSessionCountByUsername.put(extractUsername(principal), activeSessionCount);
            }
        }
        return activeSessionCountByUsername;
    }

    /** 아이디의 모든 활성 세션 만료 처리 > 종료한 세션 수 + 감사 로그 */
    public int terminateSessions(String username) {
        int terminatedCount = 0;
        for (Object principal : sessionRegistry.getAllPrincipals()) {
            if (!extractUsername(principal).equals(username)) {
                continue;
            }
            for (SessionInformation sessionInformation : findActiveSessions(principal)) {
                sessionInformation.expireNow();
                terminatedCount++;
            }
        }
        log.info("[admin session] terminated : username={}, count={}", username, terminatedCount);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.ADMIN_ACCOUNT, username,
                AdminAuditAction.SESSION_TERMINATE, null, AdminAuditEvent.summary("terminatedCount", terminatedCount)));
        return terminatedCount;
    }

    private List<SessionInformation> findActiveSessions(Object principal) {
        return sessionRegistry.getAllSessions(principal, false);
    }

    private static String extractUsername(Object principal) {
        return principal instanceof UserDetails userDetails ? userDetails.getUsername() : String.valueOf(principal);
    }
}
