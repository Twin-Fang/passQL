package com.passql.member.auth.repository;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.data.redis.core.SetOperations;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.data.redis.core.script.RedisScript;

import java.time.Duration;
import java.util.Collection;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * refresh token Redis 키 형식 (#516): 기기 키 refresh_token:{uuid}:{jti} + 회원별 기기 목록, 옛 키 refresh_token:{uuid}
 */
class RefreshTokenRepositoryTest {

    @SuppressWarnings("unchecked")
    private final ValueOperations<String, String> valueOperations = mock(ValueOperations.class);
    @SuppressWarnings("unchecked")
    private final SetOperations<String, String> setOperations = mock(SetOperations.class);
    private final StringRedisTemplate redisTemplate = mock(StringRedisTemplate.class);
    private final RefreshTokenRepository repository = new RefreshTokenRepository(redisTemplate);
    private final UUID memberUuid = UUID.fromString("11111111-2222-3333-4444-555555555555");

    {
        when(redisTemplate.opsForValue()).thenReturn(valueOperations);
        when(redisTemplate.opsForSet()).thenReturn(setOperations);
    }

    @Test
    void 기기별_키에_저장하고_회원별_기기_목록에_추가한다() {
        repository.save(memberUuid, "device-1", "token-1", 60_000);

        verify(valueOperations).set("refresh_token:" + memberUuid + ":device-1", "token-1", Duration.ofMillis(60_000));
        verify(setOperations).add("refresh_token_ids:" + memberUuid, "device-1");
        verify(redisTemplate).expire("refresh_token_ids:" + memberUuid, Duration.ofMillis(60_000));
    }

    @Test
    @SuppressWarnings("unchecked")
    void 회원_전체_삭제는_모든_기기_키와_옛_키와_목록을_지운다() {
        when(setOperations.members("refresh_token_ids:" + memberUuid)).thenReturn(Set.of("device-1", "device-2"));

        repository.deleteAllByMemberUuid(memberUuid);

        ArgumentCaptor<Collection<String>> captor = ArgumentCaptor.forClass(Collection.class);
        verify(redisTemplate).delete(captor.capture());
        assertThat(captor.getValue()).containsExactlyInAnyOrder(
                "refresh_token:" + memberUuid + ":device-1",
                "refresh_token:" + memberUuid + ":device-2",
                "refresh_token:" + memberUuid,
                "refresh_token_ids:" + memberUuid);
    }

    @Test
    @SuppressWarnings("unchecked")
    void 기기_키_비교_삭제는_스크립트_한_번으로_실행한다() {
        when(redisTemplate.execute(any(RedisScript.class), eq(java.util.List.of(
                "refresh_token:" + memberUuid + ":device-1", "refresh_token_ids:" + memberUuid)),
                eq("token-1"), eq("device-1"))).thenReturn(1L);

        assertThat(repository.deleteIfMatches(memberUuid, "device-1", "token-1")).isTrue();
    }

    @Test
    @SuppressWarnings("unchecked")
    void 값이_다르거나_키가_없으면_스크립트가_0을_돌려_삭제하지_않은_것으로_본다() {
        when(redisTemplate.execute(any(RedisScript.class), any(java.util.List.class), any(), any())).thenReturn(0L);

        assertThat(repository.deleteIfMatches(memberUuid, "device-1", "stale-token")).isFalse();
    }

    @Test
    @SuppressWarnings("unchecked")
    void 옛_키_비교_삭제도_스크립트로_실행한다() {
        when(redisTemplate.execute(any(RedisScript.class), eq(java.util.List.of("refresh_token:" + memberUuid)),
                eq("legacy-token"))).thenReturn(1L);

        assertThat(repository.deleteLegacyIfMatches(memberUuid, "legacy-token")).isTrue();
    }

    @Test
    void 기기_목록에_있는_토큰_ID_인지_확인한다() {
        when(setOperations.isMember("refresh_token_ids:" + memberUuid, "device-1")).thenReturn(true);

        assertThat(repository.isActiveTokenId(memberUuid, "device-1")).isTrue();
        assertThat(repository.isActiveTokenId(memberUuid, "device-2")).isFalse();
    }
}
