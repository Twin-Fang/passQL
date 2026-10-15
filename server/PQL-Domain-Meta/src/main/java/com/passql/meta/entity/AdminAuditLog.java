package com.passql.meta.entity;

import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 관리자 감사 로그 1건: 누가(관리자·IP) 언제 무엇을(대상 종류·id) 어떻게(동작) 바꿨는지 + 변경 전후 요약 JSON
 * 수정·삭제하지 않는 기록 테이블 (BaseEntity 미상속)
 */
@Entity
@Table(
    name = "admin_audit_log",
    indexes = {
        @Index(name = "idx_admin_audit_log_occurred_at", columnList = "occurred_at"),
        @Index(name = "idx_admin_audit_log_admin_username", columnList = "admin_username"),
        @Index(name = "idx_admin_audit_log_target", columnList = "target_type, target_id")
    }
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AdminAuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID adminAuditLogUuid;

    // 관리자 아이디 (관리자 세션 밖이면 system)
    @Column(nullable = false, length = 50)
    private String adminUsername;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private AdminAuditTargetType targetType;

    // 대상 식별자 (UUID·설정 키·토픽 코드 등)
    @Column(length = 100)
    private String targetId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private AdminAuditAction action;

    // {"before": {...}, "after": {...}} (최대 AdminAuditLogService.MAX_CHANGE_SUMMARY_LENGTH 자)
    @Column(columnDefinition = "TEXT")
    private String changeSummaryJson;

    @Column(length = 64)
    private String clientIp;

    @Column(nullable = false)
    private LocalDateTime occurredAt;

    public static AdminAuditLog of(String adminUsername, AdminAuditTargetType targetType, String targetId,
                                   AdminAuditAction action, String changeSummaryJson, String clientIp) {
        AdminAuditLog auditLog = new AdminAuditLog();
        auditLog.adminUsername = adminUsername;
        auditLog.targetType = targetType;
        auditLog.targetId = targetId;
        auditLog.action = action;
        auditLog.changeSummaryJson = changeSummaryJson;
        auditLog.clientIp = clientIp;
        auditLog.occurredAt = LocalDateTime.now();
        return auditLog;
    }
}
