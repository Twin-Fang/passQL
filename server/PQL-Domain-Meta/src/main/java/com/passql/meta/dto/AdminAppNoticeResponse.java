package com.passql.meta.dto;

import com.passql.meta.entity.AppNotice;

import java.time.LocalDateTime;
import java.util.UUID;

/** 관리자 공지 목록 한 줄: 노출 설정 + 우선순위 (앱 응답 AppNoticeResponse 와 분리, 앱 API 계약 불변) */
public record AdminAppNoticeResponse(
        UUID noticeUuid,
        String title,
        String body,
        LocalDateTime startsAt,
        LocalDateTime endsAt,
        Boolean isActive,
        Boolean isImportant,
        Integer displayPriority
) {
    public static AdminAppNoticeResponse from(AppNotice notice) {
        return new AdminAppNoticeResponse(
                notice.getAppNoticeUuid(),
                notice.getTitle(),
                notice.getBody(),
                notice.getStartsAt(),
                notice.getEndsAt(),
                notice.getIsActive(),
                notice.getIsImportant(),
                notice.getDisplayPriority()
        );
    }
}
