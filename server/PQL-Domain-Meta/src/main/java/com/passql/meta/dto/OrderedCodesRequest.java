package com.passql.meta.dto;

import jakarta.validation.constraints.NotEmpty;

import java.util.List;

/** 목록 순서 변경 요청 (토픽·서브토픽·개념 태그, orderedCodes: 목록 전체 코드를 새 순서대로) */
public record OrderedCodesRequest(@NotEmpty List<String> orderedCodes) {}
