package com.passql.web.init;

import com.passql.meta.service.AppSettingService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

/**
 * 기동 시 설정 동기화 3개: Gemini 키, 샌드박스 동시 실행 수, 샌드박스 대기 시간
 * DB 값 우선, DB 가 비었을 때만 yml 값으로 채움 (AppSettingService.syncSettingToRedis)
 */
@Component
@RequiredArgsConstructor
public class AppInitializer implements ApplicationRunner {

    @Value("${gemini.api-key:}")
    private String geminiApiKeyFromYml;

    @Value("${sandbox.pool.concurrency:30}")
    private int sandboxConcurrencyFromYml;

    @Value("${sandbox.pool.wait-seconds:60}")
    private int sandboxWaitSecondsFromYml;

    private final AppSettingService appSettingService;

    @Override
    public void run(ApplicationArguments args) {
        appSettingService.syncSettingToRedis("ai.gemini_api_key", geminiApiKeyFromYml);
        appSettingService.syncSettingToRedis("sandbox.pool.concurrency", String.valueOf(sandboxConcurrencyFromYml));
        appSettingService.syncSettingToRedis("sandbox.pool.wait_seconds", String.valueOf(sandboxWaitSecondsFromYml));
    }
}
