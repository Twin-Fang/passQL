package com.passql.meta.dto;

/**
 * 플랫폼 1개의 버전 정책: 최소 버전(미만 차단), 권장 버전(미만 안내), 스토어 링크(없으면 null)
 */
public record AppPlatformVersionResponse(
        String minimumVersion,
        String recommendedVersion,
        String storeUrl
) {
}
