package com.passql.member.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

/** 회원 활동 기록 (#557): 시간당 회원 1회 DB 기록, 최근 5분 온라인 수, 1시간 지난 메모리 정리 */
class MemberActivityRecorderTest {

    private static final LocalDateTime START_TIME = LocalDateTime.of(2026, 10, 20, 14, 10);

    private MemberActivityHourService memberActivityHourService;
    private MutableClock clock;
    private MemberActivityRecorder memberActivityRecorder;

    @BeforeEach
    void setUp() {
        memberActivityHourService = mock(MemberActivityHourService.class);
        clock = new MutableClock(START_TIME);
        memberActivityRecorder = new MemberActivityRecorder(memberActivityHourService, clock);
    }

    @Test
    void 같은_시간_안의_반복_활동은_한_번만_기록() {
        UUID memberUuid = UUID.randomUUID();

        memberActivityRecorder.recordActivity(memberUuid);
        clock.setTime(START_TIME.plusMinutes(30));
        memberActivityRecorder.recordActivity(memberUuid);

        verify(memberActivityHourService, times(1)).recordActivityHour(memberUuid, LocalDateTime.of(2026, 10, 20, 14, 0));
    }

    @Test
    void 시간이_바뀌면_다시_기록() {
        UUID memberUuid = UUID.randomUUID();

        memberActivityRecorder.recordActivity(memberUuid);
        clock.setTime(START_TIME.plusMinutes(55));
        memberActivityRecorder.recordActivity(memberUuid);

        verify(memberActivityHourService).recordActivityHour(memberUuid, LocalDateTime.of(2026, 10, 20, 14, 0));
        verify(memberActivityHourService).recordActivityHour(memberUuid, LocalDateTime.of(2026, 10, 20, 15, 0));
        verify(memberActivityHourService, times(2)).recordActivityHour(any(), any());
    }

    @Test
    void 온라인_수는_최근_5분_안에_활동한_회원만() {
        memberActivityRecorder.recordActivity(UUID.randomUUID());
        clock.setTime(START_TIME.plusMinutes(4));
        memberActivityRecorder.recordActivity(UUID.randomUUID());

        assertThat(memberActivityRecorder.countOnlineMembers()).isEqualTo(2);

        clock.setTime(START_TIME.plusMinutes(6));
        assertThat(memberActivityRecorder.countOnlineMembers()).isEqualTo(1);
    }

    @Test
    void 한_시간_넘게_활동_없는_항목은_정리() {
        memberActivityRecorder.recordActivity(UUID.randomUUID());
        clock.setTime(START_TIME.plusMinutes(50));
        memberActivityRecorder.recordActivity(UUID.randomUUID());

        clock.setTime(START_TIME.plusMinutes(61));
        assertThat(memberActivityRecorder.removeStaleActivities()).isEqualTo(1);
    }

    /** 테스트용 시계 (로컬 시간 = UTC 고정) */
    private static final class MutableClock extends Clock {
        private Instant currentInstant;

        MutableClock(LocalDateTime startTime) {
            setTime(startTime);
        }

        void setTime(LocalDateTime time) {
            currentInstant = time.toInstant(ZoneOffset.UTC);
        }

        @Override
        public ZoneId getZone() {
            return ZoneOffset.UTC;
        }

        @Override
        public Clock withZone(ZoneId zone) {
            return this;
        }

        @Override
        public Instant instant() {
            return currentInstant;
        }
    }
}
