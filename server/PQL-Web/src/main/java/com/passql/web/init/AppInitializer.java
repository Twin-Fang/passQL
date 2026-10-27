package com.passql.web.init;

import com.passql.ai.service.AiConnectionRegistry;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

/**
 * 기동 시 동기화: AI 연결(기존 키 이관 > AI 서버용 목록), 단가표, 샌드박스 동시 실행 수·대기 시간
 * DB 값 우선, DB 가 비었을 때만 yml 값으로 채움
 */
@Component
@RequiredArgsConstructor
public class AppInitializer implements ApplicationRunner {

    @Value("${gemini.api-key:}")
    private String geminiApiKeyFromYml;

    @Value("${claude.api-key:}")
    private String claudeApiKeyFromYml;

    @Value("${sandbox.pool.concurrency:30}")
    private int sandboxConcurrencyFromYml;

    @Value("${sandbox.pool.wait-seconds:60}")
    private int sandboxWaitSecondsFromYml;

    private final AppSettingService appSettingService;
    private final AiConnectionRegistry aiConnectionRegistry;

    @Override
    public void run(ApplicationArguments args) {
        // AI 연결: 연결이 없으면 기존 키 이관 (#695) > AI 서버가 읽는 Redis 목록 갱신
        aiConnectionRegistry.importLegacyKeysIfEmpty(claudeApiKeyFromYml, geminiApiKeyFromYml);
        aiConnectionRegistry.syncConnectionsToRedis();
        // 마이그레이션이 단가표를 바꿔도 Redis 의 옛 값이 남지 않게 DB 값으로 덮어씀
        appSettingService.syncSettingToRedis(AppSettingKeys.AI_MODEL_PRICE_TABLE, "");
        appSettingService.syncSettingToRedis(AppSettingKeys.SANDBOX_POOL_CONCURRENCY, String.valueOf(sandboxConcurrencyFromYml));
        appSettingService.syncSettingToRedis(AppSettingKeys.SANDBOX_POOL_WAIT_SECONDS, String.valueOf(sandboxWaitSecondsFromYml));
    }
}
