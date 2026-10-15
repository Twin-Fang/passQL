package com.passql.meta.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.common.audit.AdminAuditEvent;
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
            specification = specification.and((root, query, builder) ->
                    builder.equal(root.get("adminUsername"), condition.getAdminUsername().trim()));
        }
        if (StringUtils.hasText(condition.getTargetType())) {
            AdminAuditTargetType targetType = RequestEnumParser.parse(AdminAuditTargetType.class, condition.getTargetType());
            specification = specification.and((root, query, builder) -> builder.equal(root.get("targetType"), targetType));
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
