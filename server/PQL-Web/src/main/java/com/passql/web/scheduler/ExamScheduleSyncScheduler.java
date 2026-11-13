package com.passql.web.scheduler;

import com.passql.common.util.ServiceTimeZone;
import com.passql.meta.constant.ExamScheduleSyncTrigger;
import com.passql.meta.service.ExamScheduleSyncService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * SQLD 시험 일정 자동 수집 (#991): 매일 06:05 KST 공식 페이지 1회 수집
 * 실패는 ExamScheduleSyncService 가 기록 (예외 전파 없음), 서버 2대 동시 실행은 DB 잠금으로 1대만 반영
 */
@Component
@RequiredArgsConstructor
public class ExamScheduleSyncScheduler {

    private final ExamScheduleSyncService examScheduleSyncService;

    /** 매일 06시 05분 (오전 알림 규칙 발송 전, 새벽 정리 작업과 겹치지 않게) */
    @Scheduled(cron = "0 5 6 * * *", zone = ServiceTimeZone.ZONE_NAME)
    public void syncExamSchedules() {
        examScheduleSyncService.syncNow(ExamScheduleSyncTrigger.SCHEDULED);
    }
}
