package com.passql.question.dto;

import java.util.List;

/**
 * 관리자 화면 태그 묶음 1개: 네임스페이스 앞부분(기타 묶음은 null), 표시 이름(출처·유형·회차 등), 값 목록
 * 기타 묶음 값은 태그 전체 (new-type, review:needed)
 */
public record QuestionInternalTagGroup(
        String namespacePrefix,
        String label,
        List<String> values
) {}
