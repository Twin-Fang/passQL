package com.passql.web.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Configuration
@EnableAsync
public class AsyncConfig {

    @Bean("aiTaskExecutor")
    public Executor aiTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(4);
        executor.setMaxPoolSize(8);
        executor.setQueueCapacity(50);
        executor.setThreadNamePrefix("ai-prefetch-");
        executor.initialize();
        return executor;
    }

    /**
     * SSE 스트림 작업용: 요청마다 가상 스레드 1개 (대기 위주 작업이라 풀 상한 없음)
     * TaskExecutor 가 아니어서 @Async 기본 실행기 선택에 영향 없음
     */
    @Bean(name = "sseStreamExecutor", destroyMethod = "shutdown")
    public ExecutorService sseStreamExecutor() {
        return Executors.newVirtualThreadPerTaskExecutor();
    }
}
