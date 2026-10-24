package com.passql.meta.repository;

import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.meta.entity.AdminAuditLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.util.List;
import java.util.UUID;

public interface AdminAuditLogRepository extends JpaRepository<AdminAuditLog, UUID>, JpaSpecificationExecutor<AdminAuditLog> {

    // 대상 1건의 최근 변경 50건 (idx_admin_audit_log_target 사용, 회원 이용권 변동 타임라인용)
    List<AdminAuditLog> findTop50ByTargetTypeAndTargetIdOrderByOccurredAtDesc(AdminAuditTargetType targetType, String targetId);
}
