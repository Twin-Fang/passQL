package com.passql.submission.dto.mockexam;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.UUID;

/**
 * 초안 문항 교체: 문제 UUID 지정(출제 가능해야 함) 또는 null 이면 같은 토픽에서 자동
 */
public record AdminMockExamItemReplaceRequest(@Schema(nullable = true) UUID questionUuid) {
}
