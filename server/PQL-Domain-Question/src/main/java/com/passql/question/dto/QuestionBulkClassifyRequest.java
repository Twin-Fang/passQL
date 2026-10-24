package com.passql.question.dto;

import java.util.List;
import java.util.UUID;

/**
 * 선택 문제 일괄 토픽·난이도 변경 요청: 값이 있는 항목만 변경 (둘 다 없으면 거부)
 * subtopicCode 는 topicCode 와 함께만 지정, 토픽만 바뀌면 서브토픽은 비움
 */
public record QuestionBulkClassifyRequest(
        List<UUID> questionUuids,
        String topicCode,
        String subtopicCode,
        Integer difficulty
) {}
