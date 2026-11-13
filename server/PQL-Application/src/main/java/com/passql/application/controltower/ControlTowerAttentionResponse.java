package com.passql.application.controltower;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;
import java.util.List;

/**
 * 관제소 attention v1 스냅샷 응답: schema·version 고정, 만든 시각(UTC), 항목 전체 (0건 항목 포함)
 */
public record ControlTowerAttentionResponse(
    String schema,
    String version,
    ControlTowerAttentionSource source,
    // UTC ISO 8601 문자열 고정 (전역 Jackson 설정과 무관하게 숫자 시각으로 나가지 않게)
    @JsonProperty("generated_at") @JsonFormat(shape = JsonFormat.Shape.STRING) Instant generatedAt,
    List<ControlTowerAttentionItem> items) {

    // attention 규격 이름·버전 (주 버전 1)
    static final String SCHEMA_NAME = "attention";
    static final String SCHEMA_VERSION = "1.0";

    static ControlTowerAttentionResponse of(ControlTowerAttentionSource source, Instant generatedAt,
                                            List<ControlTowerAttentionItem> items) {
        return new ControlTowerAttentionResponse(SCHEMA_NAME, SCHEMA_VERSION, source, generatedAt, items);
    }
}
