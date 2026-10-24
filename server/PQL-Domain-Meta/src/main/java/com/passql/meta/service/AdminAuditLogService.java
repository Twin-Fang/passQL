package com.passql.meta.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.util.AdminRequestContext;
import com.passql.common.util.RequestEnumParser;
import com.passql.meta.dto.AdminAuditLogSearchCondition;
import com.passql.meta.entity.AdminAuditLog;
import com.passql.meta.repository.AdminAuditLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;
import org.springframework.util.StringUtils;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 관리자 감사 로그 기록 공통 지점 + 조회
 * 기록: AdminAuditEvent > 커밋 후 새 트랜잭션 저장 (롤백된 변경은 남지 않음, 기록 실패는 원 요청에 번지지 않음)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminAuditLogService {

    // 변경 요약 JSON 최대 길이 (자, 초과분은 잘라서 저장)
    public static final int MAX_CHANGE_SUMMARY_LENGTH = 4000;

    // admin_audit_log 컬럼 길이: admin_username 50, target_id 100, client_ip 64
    private static final int MAX_ACCESS_USERNAME_LENGTH = 50;
    private static final int MAX_CLIENT_IP_LENGTH = 64;
    // LIKE 이스케이프 문자
    private static final String LIKE_ESCAPE = "\\";

    private final AdminAuditLogRepository adminAuditLogRepository;
    private final ObjectMapper objectMapper;

    /** 감사 이벤트 1건 저장 (트랜잭션 없이 발행돼도 바로 저장) */
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void record(AdminAuditEvent event) {
        try {
            AdminAuditLog auditLog = AdminAuditLog.of(
                    AdminRequestContext.findAdminUsernameOrSystem(),
                    event.targetType(),
                    event.targetId(),
                    event.action(),
                    toChangeSummaryJson(event),
                    AdminRequestContext.findClientIp().orElse(null));
            adminAuditLogRepository.save(auditLog);
        } catch (Exception e) {
            log.warn("[admin audit] record failed : target={}, action={}, error={}",
                    event.targetType(), event.action(), e.getClass().getSimpleName());
        }
    }

    /** 필터 조건 > 최신순 페이지 */
    public Page<AdminAuditLog> search(AdminAuditLogSearchCondition condition, Pageable pageable) {
        Specification<AdminAuditLog> specification = (root, query, builder) -> builder.conjunction();
        if (StringUtils.hasText(condition.getAdminUsername())) {
            specification = specification.and(containsIgnoreCase("adminUsername", condition.getAdminUsername()));
        }
        if (StringUtils.hasText(condition.getAction())) {
            AdminAuditAction action = RequestEnumParser.parse(AdminAuditAction.class, condition.getAction());
            specification = specification.and((root, query, builder) -> builder.equal(root.get("action"), action));
        }
        if (StringUtils.hasText(condition.getTargetType())) {
            AdminAuditTargetType targetType = RequestEnumParser.parse(AdminAuditTargetType.class, condition.getTargetType());
            specification = specification.and((root, query, builder) -> builder.equal(root.get("targetType"), targetType));
        }
        if (StringUtils.hasText(condition.getTargetId())) {
            specification = specification.and(containsIgnoreCase("targetId", condition.getTargetId()));
        }
        if (StringUtils.hasText(condition.getKeyword())) {
            specification = specification.and(containsIgnoreCase("targetId", condition.getKeyword())
                    .or(containsIgnoreCase("changeSummaryJson", condition.getKeyword())));
        }
        if (condition.getFromDate() != null) {
            specification = specification.and((root, query, builder) ->
                    builder.greaterThanOrEqualTo(root.get("occurredAt"), condition.getFromDate().atStartOfDay()));
        }
        if (condition.getToDate() != null) {
            specification = specification.and((root, query, builder) ->
                    builder.lessThan(root.get("occurredAt"), condition.getToDate().plusDays(1).atStartOfDay()));
        }
        return adminAuditLogRepository.findAll(specification, pageable);
    }

    /** 필드 부분 일치 (대소문자 무시, LIKE 와일드카드는 문자로 취급) */
    private Specification<AdminAuditLog> containsIgnoreCase(String fieldName, String keyword) {
        String escapedKeyword = keyword.trim().toLowerCase()
                .replace(LIKE_ESCAPE, LIKE_ESCAPE + LIKE_ESCAPE)
                .replace("%", LIKE_ESCAPE + "%")
                .replace("_", LIKE_ESCAPE + "_");
        return (root, query, builder) ->
                builder.like(builder.lower(root.get(fieldName)), "%" + escapedKeyword + "%", LIKE_ESCAPE.charAt(0));
    }

    /**
     * 접근 이벤트 1건 저장 (로그인·로그인 실패): 세션 밖에서도 호출되므로 관리자 아이디·IP 를 직접 받음
     * 비밀번호·토큰은 받지 않음, 외부 입력 값은 정리 후 저장 (기록 실패는 호출 쪽에 번지지 않음)
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void recordAccessEvent(String adminUsername, String targetId, AdminAuditAction action,
                                  Map<String, Object> summary, String clientIp) {
        try {
            String changeSummaryJson = summary == null ? null
                    : objectMapper.writeValueAsString(Map.of("before", Map.of(), "after", summary));
            adminAuditLogRepository.save(AdminAuditLog.of(
                    sanitizeForStorage(adminUsername, MAX_ACCESS_USERNAME_LENGTH),
                    AdminAuditTargetType.ADMIN_ACCOUNT,
                    targetId == null ? null : sanitizeForStorage(targetId, MAX_ACCESS_USERNAME_LENGTH),
                    action, changeSummaryJson,
                    clientIp == null ? null : sanitizeForStorage(clientIp, MAX_CLIENT_IP_LENGTH)));
        } catch (Exception e) {
            log.warn("[admin audit] access record failed : action={}, error={}", action, e.getClass().getSimpleName());
        }
    }

    /** 제어문자 제거 + 길이 제한 (DB 컬럼 길이 초과 방지) */
    private String sanitizeForStorage(String value, int maxLength) {
        String cleaned = value.replaceAll("\\p{Cntrl}", "").trim();
        return cleaned.length() > maxLength ? cleaned.substring(0, maxLength) : cleaned;
    }

    /** 변경 전후 > {"before":..,"after":..} JSON (둘 다 없으면 null, 길이 제한) */
    private String toChangeSummaryJson(AdminAuditEvent event) throws Exception {
        if (event.before() == null && event.after() == null) {
            return null;
        }
        Map<String, Object> summary = new LinkedHashMap<>();
        summary.put("before", event.before());
        summary.put("after", event.after());
        String json = objectMapper.writeValueAsString(summary);
        return json.length() > MAX_CHANGE_SUMMARY_LENGTH ? json.substring(0, MAX_CHANGE_SUMMARY_LENGTH) : json;
    }
}
