package com.passql.web.init;

import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

/**
 * 기동 시 설정 동기화 3개: Gemini 키(암호화 전환), 샌드박스 동시 실행 수, 샌드박스 대기 시간
 * DB 값 우선, DB 가 비었을 때만 yml 값으로 채움 (syncSecretSetting · syncSettingToRedis)
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
        // 비밀값은 암호화 저장 (DB 평문이면 전환)
        appSettingService.syncSecretSetting(AppSettingKeys.AI_GEMINI_API_KEY, geminiApiKeyFromYml);
        appSettingService.syncSettingToRedis(AppSettingKeys.SANDBOX_POOL_CONCURRENCY, String.valueOf(sandboxConcurrencyFromYml));
        appSettingService.syncSettingToRedis(AppSettingKeys.SANDBOX_POOL_WAIT_SECONDS, String.valueOf(sandboxWaitSecondsFromYml));
    }
}
