package com.passql.member.auth.repository;

import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.data.redis.core.script.RedisScript;
import org.springframework.stereotype.Repository;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;

/**
 * refresh token Redis 저장소 (#516): 기기별 키, 회원별 기기 목록, 옛 단일 키 호환
 * 기기 키: refresh_token:{memberUuid}:{tokenId}, 기기 목록: refresh_token_ids:{memberUuid}, 옛 키: refresh_token:{memberUuid}
 */
@Repository
@RequiredArgsConstructor
public class RefreshTokenRepository {

    // 옛 키 접두사와 같음 (기기 키는 뒤에 :{tokenId} 추가)
    private static final String KEY_PREFIX = "refresh_token:";
    private static final String TOKEN_ID_SET_KEY_PREFIX = "refresh_token_ids:";
    // 스크립트 결과: 삭제함 1, 값 불일치·키 없음 0
    private static final long SCRIPT_DELETED = 1L;

    // 기기 키 비교·삭제 (KEYS: 기기 키, 기기 목록 / ARGV: 토큰, 토큰 ID), 동시 재발급 중 한 요청만 성공
    private static final RedisScript<Long> COMPARE_AND_DELETE_DEVICE_TOKEN = new DefaultRedisScript<>(
            "if redis.call('GET', KEYS[1]) == ARGV[1] then "
                    + "redis.call('DEL', KEYS[1]) redis.call('SREM', KEYS[2], ARGV[2]) return 1 "
                    + "end return 0", Long.class);
    // 옛 단일 키 비교·삭제 (KEYS: 옛 키 / ARGV: 토큰)
    private static final RedisScript<Long> COMPARE_AND_DELETE_LEGACY_TOKEN = new DefaultRedisScript<>(
            "if redis.call('GET', KEYS[1]) == ARGV[1] then redis.call('DEL', KEYS[1]) return 1 end return 0", Long.class);

    private final StringRedisTemplate stringRedisTemplate;

    /** 기기 키 저장 > 회원별 기기 목록 추가 (목록 만료도 최신 토큰 기준으로 연장) */
    public void save(UUID memberUuid, String tokenId, String refreshToken, long ttlMillis) {
        Duration ttl = Duration.ofMillis(ttlMillis);
        stringRedisTemplate.opsForValue().set(deviceKeyOf(memberUuid, tokenId), refreshToken, ttl);
        stringRedisTemplate.opsForSet().add(tokenIdSetKeyOf(memberUuid), tokenId);
        stringRedisTemplate.expire(tokenIdSetKeyOf(memberUuid), ttl);
    }

    /** 저장값 일치 시에만 기기 키 삭제 + 목록 제거 (원자적), 삭제했으면 true */
    public boolean deleteIfMatches(UUID memberUuid, String tokenId, String refreshToken) {
        Long result = stringRedisTemplate.execute(COMPARE_AND_DELETE_DEVICE_TOKEN,
                List.of(deviceKeyOf(memberUuid, tokenId), tokenIdSetKeyOf(memberUuid)), refreshToken, tokenId);
        return result != null && result == SCRIPT_DELETED;
    }

    /** 옛 단일 키: 저장값 일치 시에만 삭제 (원자적, 기기별 저장 전 발급분), 삭제했으면 true */
    public boolean deleteLegacyIfMatches(UUID memberUuid, String refreshToken) {
        Long result = stringRedisTemplate.execute(COMPARE_AND_DELETE_LEGACY_TOKEN,
                List.of(legacyKeyOf(memberUuid)), refreshToken);
        return result != null && result == SCRIPT_DELETED;
    }

    /** 회원 기기 목록에 남아 있는 토큰 ID 인지 (회전·로그아웃되면 목록에서 빠짐) */
    public boolean isActiveTokenId(UUID memberUuid, String tokenId) {
        return Boolean.TRUE.equals(stringRedisTemplate.opsForSet().isMember(tokenIdSetKeyOf(memberUuid), tokenId));
    }

    /** 회원 전체 세션 삭제 (탈퇴): 모든 기기 키 + 옛 키 + 기기 목록 */
    public void deleteAllByMemberUuid(UUID memberUuid) {
        List<String> keys = new ArrayList<>();
        Set<String> tokenIds = stringRedisTemplate.opsForSet().members(tokenIdSetKeyOf(memberUuid));
        if (tokenIds != null) {
            tokenIds.forEach(tokenId -> keys.add(deviceKeyOf(memberUuid, tokenId)));
        }
        keys.add(legacyKeyOf(memberUuid));
        keys.add(tokenIdSetKeyOf(memberUuid));
        stringRedisTemplate.delete(keys);
    }

    private static String deviceKeyOf(UUID memberUuid, String tokenId) {
        return KEY_PREFIX + memberUuid + ":" + tokenId;
    }

    private static String legacyKeyOf(UUID memberUuid) {
        return KEY_PREFIX + memberUuid;
    }

    private static String tokenIdSetKeyOf(UUID memberUuid) {
        return TOKEN_ID_SET_KEY_PREFIX + memberUuid;
    }
}
