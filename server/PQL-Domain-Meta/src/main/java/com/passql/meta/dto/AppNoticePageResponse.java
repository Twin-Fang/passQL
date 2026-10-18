package com.passql.meta.dto;

import java.util.List;

/**
 * 공지 목록 한 페이지: 공지, 현재 페이지(0부터), 다음 페이지 유무
 */
public record AppNoticePageResponse(
        List<AppNoticeResponse> notices,
        Integer page,
        Boolean hasNextPage
) {
}
