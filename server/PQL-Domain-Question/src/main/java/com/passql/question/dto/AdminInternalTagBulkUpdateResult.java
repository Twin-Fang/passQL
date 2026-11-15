package com.passql.question.dto;

import java.util.List;
import java.util.UUID;

/**
 * 관리자 내부 태그 일괄 변경 결과: 요청 수, 태그가 바뀐 수, 없는 UUID, 문제당 최대 개수 초과로 건너뛴 UUID (#1117)
 */
public record AdminInternalTagBulkUpdateResult(
        Integer requestedCount,
        Integer changedCount,
        List<UUID> notFoundQuestionUuids,
        List<UUID> tagLimitExceededQuestionUuids
) {}
