package com.passql.question.dto;

import java.util.List;

/**
 * 관리자 내부 태그 요약 묶음 1개: 네임스페이스(기타 묶음은 null)별 값·문제 수 (#1117)
 */
public record AdminInternalTagSummaryGroup(
        String namespacePrefix,
        String label,
        List<TagCount> tagCounts
) {
    /** 태그 1개 문제 수: tag 전체, value 표시값, 전체 문제 수, 활성 문제 수 */
    public record TagCount(
            String tag,
            String value,
            Long questionCount,
            Long activeQuestionCount
    ) {}
}
