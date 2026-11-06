package com.passql.ai.dto;

import jakarta.validation.constraints.NotNull;

import java.util.UUID;

/** 선택지 해설(동기) 요청: 문제, 고른 보기 (생략 시 마지막 제출의 보기) */
public record DiffExplainRequest(
    @NotNull UUID questionUuid,
    String selectedChoiceKey
) {
}
