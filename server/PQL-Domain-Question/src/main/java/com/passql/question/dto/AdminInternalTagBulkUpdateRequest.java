package com.passql.question.dto;

import java.util.List;
import java.util.UUID;

/**
 * 관리자 내부 태그 일괄 변경 요청: 문제 UUID 목록 + 붙일 태그 + 뗄 태그 (둘 중 하나 이상, #1117)
 */
public record AdminInternalTagBulkUpdateRequest(
        List<UUID> questionUuids,
        List<String> addTags,
        List<String> removeTags
) {}
