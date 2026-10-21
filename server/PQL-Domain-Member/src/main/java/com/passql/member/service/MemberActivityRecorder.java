package com.passql.member.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.Clock;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 회원 활동 기록: 메모리에 마지막 활동 시각(온라인 수), 회원별 시간이 바뀔 때만 DB 기록(시간당 회원 1회) (#557)
 * 단일 인스턴스 전제, 재시작 시 온라인 수는 5분 안에 복구
 */
@Service
public class MemberActivityRecorder {

    // 온라인 판정 기준 (최근 5분 안에 활동한 회원)
    public static final long ONLINE_WINDOW_MINUTES = 5;
    // 메모리 항목 보관 상한 (1시간 넘게 활동 없으면 정리)
    public static final long STALE_ACTIVITY_MINUTES = 60;

    private final MemberActivityHourService memberActivityHourService;
    private final Clock clock;

    // 회원별 마지막 활동 (마지막 활동 시각, 마지막으로 DB 기록한 시간)
    private final Map<UUID, ActivityMark> activityMarkByMember = new ConcurrentHashMap<>();

    private record ActivityMark(LocalDateTime lastActivityAt, LocalDateTime recordedActivityHour) {
    }

    @Autowired
    public MemberActivityRecorder(MemberActivityHourService memberActivityHourService) {
        this(memberActivityHourService, Clock.systemDefaultZone());
    }

    MemberActivityRecorder(MemberActivityHourService memberActivityHourService, Clock clock) {
        this.memberActivityHourService = memberActivityHourService;
        this.clock = clock;
    }

    /** 활동 1회: 마지막 활동 시각 갱신 > 이번 시간 첫 활동이면 비동기 DB 기록 (기록 실패·대기열 초과 시 그 시간 1건 누락 허용) */
    public void recordActivity(UUID memberUuid) {
        if (memberUuid == null) {
            return;
        }
        LocalDateTime now = LocalDateTime.now(clock);
        LocalDateTime currentActivityHour = now.truncatedTo(ChronoUnit.HOURS);
        ActivityMark previousMark = activityMarkByMember.put(memberUuid, new ActivityMark(now, currentActivityHour));
        boolean isFirstActivityInHour = previousMark == null
                || !previousMark.recordedActivityHour().equals(currentActivityHour);
        if (isFirstActivityInHour) {
            memberActivityHourService.recordActivityHour(memberUuid, currentActivityHour);
        }
    }

    /** 최근 5분 안에 활동한 회원 수 */
    public long countOnlineMembers() {
        LocalDateTime onlineSince = LocalDateTime.now(clock).minusMinutes(ONLINE_WINDOW_MINUTES);
        return activityMarkByMember.values().stream()
                .filter(mark -> mark.lastActivityAt().isAfter(onlineSince))
                .count();
    }

    /** 1시간 넘게 활동 없는 메모리 항목 정리 (정리 수 반환) */
    public int removeStaleActivities() {
        LocalDateTime staleBefore = LocalDateTime.now(clock).minusMinutes(STALE_ACTIVITY_MINUTES);
        int sizeBefore = activityMarkByMember.size();
        activityMarkByMember.values().removeIf(mark -> mark.lastActivityAt().isBefore(staleBefore));
        return Math.max(0, sizeBefore - activityMarkByMember.size());
    }
}
