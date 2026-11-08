package com.passql.application.controltower;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * attention v1 source: 앱 이름, 서버 버전, 환경(production·development), 관리자 기준 주소 (없는 값은 생략)
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record ControlTowerAttentionSource(
    String app,
    @JsonProperty("app_version") String appVersion,
    String environment,
    @JsonProperty("admin_base_url") String adminBaseUrl) {
}
