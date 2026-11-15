package com.passql.application.oxquiz.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.UUID;

/** OX 카드 1장 (#1083): 개념 바로 확인 문장 + 정답·이유 (앱이 바로 채점) */
public record OxCardItem(
    @Schema(description = "카드 식별 키 ({개념 uuid}:{문장 해시 16자})")
    String cardKey,
    UUID conceptUuid,
    String conceptTitle,
    String topicName,
    String statement,
    @Schema(description = "정답 (true: O, false: X)")
    Boolean isTrue,
    String reason,
    @Schema(nullable = true, description = "현재 Leitner 칸 (1~5), 처음 보는 카드면 null")
    Integer box
) {}
