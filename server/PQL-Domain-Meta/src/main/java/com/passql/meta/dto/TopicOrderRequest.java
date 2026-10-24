package com.passql.meta.dto;

import jakarta.validation.constraints.NotEmpty;

import java.util.List;

/** 토픽·서브토픽 순서 변경 요청 (orderedCodes: 목록 전체 코드를 새 순서대로) */
public record TopicOrderRequest(@NotEmpty List<String> orderedCodes) {}
