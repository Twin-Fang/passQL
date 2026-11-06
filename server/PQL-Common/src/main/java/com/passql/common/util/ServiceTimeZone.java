package com.passql.common.util;

import java.time.ZoneId;

/**
 * 서비스 기준 시간대 (한국 표준시): 하루 경계·만료일·예약 시각·스케줄 cron 공통
 * DB 의 LocalDateTime 은 KST 로컬 저장값, 서버 JVM 시간대와 무관하게 이 값으로 계산
 */
public final class ServiceTimeZone {

    // @Scheduled(zone = ...) 처럼 컴파일 상수가 필요한 곳용 이름
    public static final String ZONE_NAME = "Asia/Seoul";
    public static final ZoneId ZONE = ZoneId.of(ZONE_NAME);

    private ServiceTimeZone() {
    }
}
