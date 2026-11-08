package com.passql.application.controltower;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * 관제소 확인할 일 연동 설정 (application.yml control-tower.attention, 값은 환경변수·운영 설정 파일로만)
 * token: 관제소 CONTROL_PULL_TOKEN_PASSQL__{SOURCE} 와 같은 값, tokenPrevious: 교체 중 이전 값 (비면 미사용)
 * adminBaseUrl: 관리자 화면 기준 주소 (https 만 내보냄, 아니면 admin_url 생략)
 */
@ConfigurationProperties(prefix = "control-tower.attention")
public record ControlTowerAttentionProperties(String token, String tokenPrevious, String adminBaseUrl) {
}
