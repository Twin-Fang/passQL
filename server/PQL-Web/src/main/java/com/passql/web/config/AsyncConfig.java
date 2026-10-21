package com.passql.web.config;

import com.passql.ai.service.AiCallLogService;
import com.passql.application.notification.NotificationDispatcher;
import com.passql.member.auth.application.SocialUnlinkService;
import com.passql.member.service.MemberActivityHourService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadPoolExecutor;

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

    /** AI 서버 호출 기록 전용 (#474): 단일 스레드, 대기 1000건 초과분은 버림 (통계용이라 요청에 영향 금지) */
    @Bean(AiCallLogService.RECORD_EXECUTOR_NAME)
    public Executor aiCallLogExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(1);
        executor.setMaxPoolSize(1);
        executor.setQueueCapacity(1000);
        executor.setThreadNamePrefix("ai-call-log-");
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.DiscardPolicy());
        executor.initialize();
        return executor;
    }

    /** 회원 시간대별 활동 기록 전용 (#557): 단일 스레드, 대기 1000건 초과분은 버림 (통계용이라 요청에 영향 금지) */
    @Bean(MemberActivityHourService.RECORD_EXECUTOR_NAME)
    public Executor memberActivityExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(1);
        executor.setMaxPoolSize(1);
        executor.setQueueCapacity(1000);
        executor.setThreadNamePrefix("member-activity-");
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.DiscardPolicy());
        executor.initialize();
        return executor;
    }

    /** 알림 팬아웃·푸시 전달 전용 (#491): 대기 100건 초과분은 거절 (후처리 로그로 확인) */
    @Bean(NotificationDispatcher.EXECUTOR_NAME)
    public Executor notificationTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(1);
        executor.setMaxPoolSize(2);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("notification-");
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.AbortPolicy());
        executor.initialize();
        return executor;
    }

    /** 탈퇴 후 제공자 연결 해제 전용 (#516): 외부 API 호출 대기 위주, 대기 100건 초과분은 거절 (탈퇴 결과에 영향 없음) */
    @Bean(SocialUnlinkService.EXECUTOR_NAME)
    public Executor socialUnlinkTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(1);
        executor.setMaxPoolSize(2);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("social-unlink-");
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.AbortPolicy());
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
