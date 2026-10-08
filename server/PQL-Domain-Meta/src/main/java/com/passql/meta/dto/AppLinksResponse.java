package com.passql.meta.dto;

/**
 * 스토어 다운로드 링크. 아직 출시 전이거나 설정이 비어 있으면 해당 필드는 null 이다.
 * 웹은 둘 다 null 이면 앱 안내 배너를 숨긴다 (#433).
 */
public record AppLinksResponse(
        String androidUrl,
        String iosUrl
) {
}
