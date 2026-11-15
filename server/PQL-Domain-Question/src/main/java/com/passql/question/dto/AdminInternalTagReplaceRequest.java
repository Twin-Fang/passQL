package com.passql.question.dto;

import java.util.List;

/**
 * 관리자 문제 1건 내부 태그 교체 요청 (빈 목록 > 전부 제거, #1117)
 */
public record AdminInternalTagReplaceRequest(
        List<String> tags
) {}
