package com.passql.member.auth.infrastructure.jwt;

import java.util.UUID;

/**
 * refresh token 클레임: 회원 UUID(sub), 기기 토큰 ID(jti, 옛 형식은 null)
 */
public record RefreshTokenClaims(UUID memberUuid, String tokenId) {

    /** jti 없는 옛 단일 키 형식 (기기별 저장 전 발급분) */
    public boolean isLegacyFormat() {
        return tokenId == null || tokenId.isBlank();
    }
}
