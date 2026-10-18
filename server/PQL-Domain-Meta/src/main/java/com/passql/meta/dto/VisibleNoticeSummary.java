package com.passql.meta.dto;

import com.passql.meta.entity.AppNotice;

import java.time.LocalDateTime;
import java.util.UUID;

/** 지금 노출 중인 공지 1건 (알림함 공지 탭용): 게시 시각 = 노출 시작, 없으면 등록 시각 */
public record VisibleNoticeSummary(
        UUID noticeUuid,
        String title,
        String body,
        Boolean isImportant,
        LocalDateTime publishedAt
) {
    public static VisibleNoticeSummary from(AppNotice notice) {
        return new VisibleNoticeSummary(notice.getAppNoticeUuid(), notice.getTitle(), notice.getBody(),
                notice.getIsImportant(), notice.resolvePublishedAt());
    }
}
