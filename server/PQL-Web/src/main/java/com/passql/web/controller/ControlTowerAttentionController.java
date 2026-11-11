package com.passql.web.controller;

import com.passql.application.controltower.ControlTowerAttentionResponse;
import com.passql.application.controltower.ControlTowerAttentionService;
import com.passql.web.config.ControlTowerSecurityConfig;
import lombok.RequiredArgsConstructor;
import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

/**
 * 관제소 확인할 일 수집 (attention v1, #959): 회원·관리자 인증 대신 X-Control-Token 검증
 */
@RestController
@RequiredArgsConstructor
public class ControlTowerAttentionController implements ControlTowerAttentionControllerDocs {

    // 관제소 수집 토큰 헤더 (attention v1 규격)
    static final String CONTROL_TOKEN_HEADER_NAME = "X-Control-Token";

    private final ControlTowerAttentionService controlTowerAttentionService;

    /** 켜짐 확인(404) > 토큰 검증(401) > 스냅샷 (JSON 고정: XML 변환기가 classpath 에 있음, 캐시 금지) */
    @Override
    @GetMapping(value = ControlTowerSecurityConfig.ATTENTION_PATH, produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ControlTowerAttentionResponse> getAttention(
            @RequestHeader(value = CONTROL_TOKEN_HEADER_NAME, required = false) String presentedToken) {
        return ResponseEntity.ok()
            .cacheControl(CacheControl.noStore())
            .body(controlTowerAttentionService.collectSnapshot(presentedToken));
    }
}
