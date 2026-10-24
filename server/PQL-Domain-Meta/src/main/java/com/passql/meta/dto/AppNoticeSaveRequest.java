package com.passql.meta.dto;

import java.time.LocalDateTime;

/**
 * 공지 등록·수정 요청 (관리자). 기간 시작·끝은 비우면 즉시·무기한, displayPriority 는 비우면 0
 */
public record AppNoticeSaveRequest(
        String title,
        String body,
        LocalDateTime startsAt,
        LocalDateTime endsAt,
        Boolean isActive,
        Boolean isImportant,
        Integer displayPriority
) {
    /** 우선순위 없는 요청 (0 으로 처리) */
    public AppNoticeSaveRequest(String title, String body, LocalDateTime startsAt, LocalDateTime endsAt,
                                Boolean isActive, Boolean isImportant) {
        this(title, body, startsAt, endsAt, isActive, isImportant, null);
    }
}
