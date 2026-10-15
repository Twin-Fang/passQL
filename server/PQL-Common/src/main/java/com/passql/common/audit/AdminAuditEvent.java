package com.passql.common.audit;

import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 관리자 변경 1건 감사 이벤트 (기록 공통 지점: Meta AdminAuditLogService 가 커밋 후 저장)
 * 서비스가 ApplicationEventPublisher 로 발행, 관리자·IP 는 기록 시점 요청에서 읽음
 * before/after: 바뀐 값 요약 (민감 값은 발행 쪽에서 마스킹, 없으면 null)
 */
public record AdminAuditEvent(
        AdminAuditTargetType targetType,
        String targetId,
        AdminAuditAction action,
        Map<String, Object> before,
        Map<String, Object> after
) {
    public static AdminAuditEvent of(AdminAuditTargetType targetType, Object targetId, AdminAuditAction action,
                                     Map<String, Object> before, Map<String, Object> after) {
        return new AdminAuditEvent(targetType, targetId == null ? null : String.valueOf(targetId), action, before, after);
    }

    /** 변경 전후 없이 대상·동작만 */
    public static AdminAuditEvent of(AdminAuditTargetType targetType, Object targetId, AdminAuditAction action) {
        return of(targetType, targetId, action, null, null);
    }

    // 요약 문자열 값 최대 길이 (본문·프롬프트 같은 긴 값은 앞부분만)
    private static final int MAX_SUMMARY_TEXT_LENGTH = 300;

    /**
     * 요약 맵 (키, 값, 키, 값 ...) — null 값 허용, 긴 문자열은 앞 300자
     */
    public static Map<String, Object> summary(Object... keyValuePairs) {
        if (keyValuePairs.length % 2 != 0) {
            throw new IllegalArgumentException("summary needs key-value pairs");
        }
        Map<String, Object> summary = new LinkedHashMap<>();
        for (int index = 0; index < keyValuePairs.length; index += 2) {
            Object value = keyValuePairs[index + 1];
            if (value instanceof String text && text.length() > MAX_SUMMARY_TEXT_LENGTH) {
                value = text.substring(0, MAX_SUMMARY_TEXT_LENGTH) + "…";
            }
            summary.put(String.valueOf(keyValuePairs[index]), value);
        }
        return summary;
    }
}
