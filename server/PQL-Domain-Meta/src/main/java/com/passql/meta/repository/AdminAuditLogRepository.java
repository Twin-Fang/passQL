package com.passql.meta.repository;

import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.meta.entity.AdminAuditLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.util.List;
import java.util.UUID;

public interface AdminAuditLogRepository extends JpaRepository<AdminAuditLog, UUID>, JpaSpecificationExecutor<AdminAuditLog> {

    /** 대상 1건의 최근 변경 이력 (최신순 20건) */
    List<AdminAuditLog> findTop20ByTargetTypeAndTargetIdOrderByOccurredAtDesc(AdminAuditTargetType targetType, String targetId);
}
