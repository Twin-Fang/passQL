package com.passql.web.support;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.common.audit.constant.AdminAuditTargetType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;

/**
 * 감사 로그 화면 표시 보조 (템플릿에서 ${@adminAuditLogViewHelper...} 로 호출)
 * 대상 종류·ID > 이동 경로, 변경 요약 JSON > 필드별 전·후 행
 */
@Component("adminAuditLogViewHelper")
@RequiredArgsConstructor
public class AdminAuditLogViewHelper {

    // 감사 요약 JSON 의 전·후 키 (AdminAuditLogService.toChangeSummaryJson)
    private static final String BEFORE_SIDE = "before";
    private static final String AFTER_SIDE = "after";

    private final ObjectMapper objectMapper;

    /** 변경 필드 1행: 이전 값과 이후 값 (한쪽에 없는 필드는 null) */
    public record ChangeRow(String fieldName, String beforeText, String afterText, boolean isChanged) {
    }

    /** 대상 종류·ID > 관리자 화면 경로 (상세가 있으면 상세, 없으면 목록, 이동할 곳이 없으면 null) */
    public String findTargetPath(AdminAuditTargetType targetType, String targetId) {
        if (targetType == null) {
            return null;
        }
        return switch (targetType) {
            case QUESTION -> toDetailPathIfUuid("/admin/questions/", targetId, "/admin/questions");
            case MEMBER -> toDetailPathIfUuid("/admin/members/", targetId, "/admin/members");
            case CHOICE_SET -> toDetailPathIfUuid("/admin/choice-sets/", targetId, "/admin/choice-sets");
            // 설정은 키 검색으로 해당 행만 보이게
            case APP_SETTING -> StringUtils.hasText(targetId)
                    ? "/admin/settings?keyword=" + URLEncoder.encode(targetId, StandardCharsets.UTF_8)
                    : "/admin/settings";
            case LEGAL -> "/admin/legal";
            case REPORT -> "/admin/reports";
            case FEEDBACK -> "/admin/feedbacks";
            case TOPIC -> "/admin/topics";
            case PROMPT -> "/admin/prompts";
            case EXAM_SCHEDULE -> "/admin/exam-schedules";
            case CONCEPT_DOC -> "/admin/concepts";
            case DAILY_CHALLENGE -> "/admin/daily-challenges";
            case NOTICE -> "/admin/app-operation";
            case ADMIN_ACCOUNT -> "/admin/accounts";
            case NOTIFICATION -> "/admin/push";
            case COMMUNITY_POST -> "/admin/community/posts";
            case EMBEDDING_INDEX -> "/admin/embeddings";
            case AI_CONNECTION -> "/admin/ai-connections";
        };
    }

    /** {"before":{..},"after":{..}} > 필드별 행 (파싱 실패·형식 다름은 빈 목록, 화면은 원문으로 대체) */
    public List<ChangeRow> toChangeRows(String changeSummaryJson) {
        if (!StringUtils.hasText(changeSummaryJson)) {
            return List.of();
        }
        try {
            JsonNode root = objectMapper.readTree(changeSummaryJson);
            JsonNode before = root.path(BEFORE_SIDE);
            JsonNode after = root.path(AFTER_SIDE);
            Set<String> fieldNames = new LinkedHashSet<>();
            before.fieldNames().forEachRemaining(fieldNames::add);
            after.fieldNames().forEachRemaining(fieldNames::add);
            List<ChangeRow> rows = new ArrayList<>();
            for (String fieldName : fieldNames) {
                String beforeText = toDisplayText(before.get(fieldName));
                String afterText = toDisplayText(after.get(fieldName));
                rows.add(new ChangeRow(fieldName, beforeText, afterText, !Objects.equals(beforeText, afterText)));
            }
            return rows;
        } catch (Exception e) {
            return List.of();
        }
    }

    private String toDetailPathIfUuid(String detailPrefix, String targetId, String listPath) {
        if (targetId != null) {
            try {
                return detailPrefix + UUID.fromString(targetId);
            } catch (IllegalArgumentException e) {
                return listPath;
            }
        }
        return listPath;
    }

    /** JSON 값 > 표시 문자열 (없음 null, JSON null 은 "null", 객체·배열은 JSON 문자열) */
    private String toDisplayText(JsonNode valueNode) {
        if (valueNode == null || valueNode.isMissingNode()) {
            return null;
        }
        return valueNode.isValueNode() ? valueNode.asText() : valueNode.toString();
    }
}
