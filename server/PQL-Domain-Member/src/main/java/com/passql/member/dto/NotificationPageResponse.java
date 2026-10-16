package com.passql.member.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/** 알림함 목록 한 페이지: 항목, 다음 페이지 커서 (마지막이면 null) */
public record NotificationPageResponse(List<NotificationItemResponse> items, @Schema(nullable = true) String nextCursor) {
}
