package com.passql.meta.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;

/** 토픽·서브토픽 추가 요청 (code: 영문 소문자·숫자·_ , 예: sql_join) */
public record TopicCreateRequest(
        @NotBlank @Pattern(regexp = "^[a-z0-9_]{2,100}$", message = "코드는 영문 소문자·숫자·_ 2~100자") String code,
        @NotBlank String displayName,
        @NotNull @Min(1) Integer sortOrder
) {}
