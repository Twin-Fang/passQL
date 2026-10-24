package com.passql.meta.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.dto.AppSettingChangeHistory;
import com.passql.meta.entity.AdminAuditLog;
import com.passql.meta.repository.AdminAuditLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 설정 변경 이력·롤백: 감사 로그(APP_SETTING)에서 변경 전후 값 읽기 > 이전 값으로 되돌려 저장
 * 저장은 AppSettingService.save 를 거침 (형식 검사·Redis 반영·감사 기록 공통)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AppSettingHistoryService {

    // 감사 요약 필드 이름 (AppSettingService 가 before·after 에 넣는 키)
    private static final String VALUE_FIELD = "value";
    private static final String BEFORE_SIDE = "before";
    private static final String AFTER_SIDE = "after";
    // AdminAuditEvent.summary 가 긴 문자열 끝에 붙이는 말줄임표 (잘린 값은 복원 불가)
    private static final String TRUNCATED_SUFFIX = "…";

    private final AdminAuditLogRepository adminAuditLogRepository;
    private final AppSettingService appSettingService;
    private final ObjectMapper objectMapper;

    /** 키별 최근 변경 이력 (최신순 20건) */
    public List<AppSettingChangeHistory> findHistory(String key) {
        boolean isSensitive = AppSettingService.isSensitiveKey(key);
        return adminAuditLogRepository.findTop20ByTargetTypeAndTargetIdOrderByOccurredAtDesc(AdminAuditTargetType.APP_SETTING, key)
                .stream()
                .map(auditLog -> toHistory(auditLog, isSensitive))
                .toList();
    }

    /** 이력 1건의 이전 값으로 복원 (키 일치·민감 값 아님·값 온전함 확인 후 저장) */
    @Transactional
    public void rollback(String key, UUID auditLogUuid) {
        AdminAuditLog auditLog = adminAuditLogRepository.findById(auditLogUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.SETTING_NOT_FOUND));
        boolean isSameSetting = auditLog.getTargetType() == AdminAuditTargetType.APP_SETTING && key.equals(auditLog.getTargetId());
        if (!isSameSetting || AppSettingService.isSensitiveKey(key)) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "복원할 수 없는 이력입니다.");
        }
        String beforeValue = readValue(auditLog.getChangeSummaryJson(), BEFORE_SIDE)
                .filter(value -> !value.endsWith(TRUNCATED_SUFFIX))
                .orElseThrow(() -> new CustomException(ErrorCode.INVALID_INPUT_VALUE, "이전 값이 없거나 잘려 있어 복원할 수 없습니다."));
        appSettingService.save(key, beforeValue);
        log.info("[app-setting rollback] restored : key={}, auditLogUuid={}", key, auditLogUuid);
    }

    private AppSettingChangeHistory toHistory(AdminAuditLog auditLog, boolean isSensitive) {
        Optional<String> beforeValue = readValue(auditLog.getChangeSummaryJson(), BEFORE_SIDE);
        Optional<String> afterValue = readValue(auditLog.getChangeSummaryJson(), AFTER_SIDE);
        boolean canRollback = !isSensitive
                && auditLog.getAction() == AdminAuditAction.UPDATE
                && beforeValue.filter(value -> !value.endsWith(TRUNCATED_SUFFIX)).isPresent();
        return new AppSettingChangeHistory(auditLog.getAdminAuditLogUuid(), auditLog.getOccurredAt(),
                auditLog.getAdminUsername(), beforeValue.orElse(null), afterValue.orElse(null), canRollback);
    }

    /** {"before":{"value":..},"after":{..}} > side 의 value (파싱 실패·없음은 빈 값) */
    private Optional<String> readValue(String changeSummaryJson, String side) {
        if (changeSummaryJson == null) {
            return Optional.empty();
        }
        try {
            JsonNode valueNode = objectMapper.readTree(changeSummaryJson).path(side).path(VALUE_FIELD);
            return valueNode.isMissingNode() || valueNode.isNull() ? Optional.empty() : Optional.of(valueNode.asText());
        } catch (Exception e) {
            return Optional.empty();
        }
    }
}
