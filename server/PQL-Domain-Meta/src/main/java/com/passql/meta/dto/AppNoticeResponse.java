package com.passql.meta.dto;

import com.passql.meta.entity.AppNotice;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 공지 1건 (앱 노출·관리자 목록 공용)
 */
public record AppNoticeResponse(
        UUID noticeUuid,
        String title,
        String body,
        LocalDateTime startsAt,
        LocalDateTime endsAt,
        Boolean isActive,
        Boolean isImportant
) {
    public static AppNoticeResponse from(AppNotice notice) {
        return new AppNoticeResponse(
                notice.getAppNoticeUuid(),
                notice.getTitle(),
                notice.getBody(),
                notice.getStartsAt(),
                notice.getEndsAt(),
                notice.getIsActive(),
                notice.getIsImportant()
        );
    }
}
