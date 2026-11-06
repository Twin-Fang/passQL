package com.passql.question.dto;

import java.util.List;

/** 선택 문제 재색인 요청: 문제 UUID 목록 (비면 EMBEDDING_INDEX_TARGET_EMPTY) */
public record IndexSelectedRequest(List<String> uuids) {
}
