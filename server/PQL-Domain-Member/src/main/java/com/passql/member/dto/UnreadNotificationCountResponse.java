package com.passql.member.dto;

/** 안 읽은 개수: 알림 탭, 공지 탭, 합계 (종 아이콘·앱 아이콘 숫자는 total) */
public record UnreadNotificationCountResponse(long general, long notice, long total) {

    public static UnreadNotificationCountResponse of(long general, long notice) {
        return new UnreadNotificationCountResponse(general, notice, general + notice);
    }
}
