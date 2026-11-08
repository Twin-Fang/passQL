package com.passql.application.controltower;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.passql.application.constant.ControlTowerAttentionLevel;

/**
 * attention v1 count 항목: key, 이름, 수준, 묶음, 관리자 주소, 처리 안 된 개수, 누적 개수 (없는 값은 생략)
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record ControlTowerAttentionItem(
    String key,
    String label,
    String kind,
    ControlTowerAttentionLevel level,
    String group,
    @JsonProperty("admin_url") String adminUrl,
    Long count,
    Long total) {

    // attention v1 kind: 개수 항목
    static final String KIND_COUNT = "count";

    /** 개수 > count 항목 (0 ok, 1 이상 info) */
    static ControlTowerAttentionItem count(String key, String label, String group, String adminUrl, long count, Long total) {
        ControlTowerAttentionLevel level = count > 0 ? ControlTowerAttentionLevel.INFO : ControlTowerAttentionLevel.OK;
        return new ControlTowerAttentionItem(key, label, KIND_COUNT, level, group, adminUrl, count, total);
    }
}
