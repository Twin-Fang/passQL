package com.passql.meta.dto;

import io.swagger.v3.oas.annotations.media.Schema;

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
        @Schema(nullable = true) LocalDateTime startsAt,
        @Schema(nullable = true) LocalDateTime endsAt,
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
