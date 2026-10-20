package com.passql.web.scheduler;

import com.passql.member.service.MemberActivityHourService;
import com.passql.member.service.MemberActivityRecorder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * 회원 활동 정리 (#557): 메모리 항목(1시간 넘게 활동 없음) 10분마다, DB 기록(400일 보관) 매일
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class MemberActivityCleanupScheduler {

    private final MemberActivityRecorder memberActivityRecorder;
    private final MemberActivityHourService memberActivityHourService;

    /** 10분마다 (온라인 수 계산 대상 맵 크기 유지) */
    @Scheduled(cron = "0 */10 * * * *", zone = "Asia/Seoul")
    public void removeStaleActivities() {
        memberActivityRecorder.removeStaleActivities();
    }

    /** 매일 04시 40분 (다른 정리 작업 04시~04시 30분과 겹치지 않게) */
    @Scheduled(cron = "0 40 4 * * *", zone = "Asia/Seoul")
    public void purgeExpired() {
        int deleted = memberActivityHourService.purgeExpired();
        if (deleted > 0) {
            log.info("[member activity] purged expired rows : count={}", deleted);
        }
    }
}
