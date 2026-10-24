package com.passql.member.repository;

import com.passql.member.entity.MemberPushToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MemberPushTokenRepository extends JpaRepository<MemberPushToken, UUID> {

    Optional<MemberPushToken> findByToken(String token);

    List<MemberPushToken> findAllByIsPushEnabledTrue();

    List<MemberPushToken> findAllByMemberUuidAndIsPushEnabledTrue(UUID memberUuid);

    List<MemberPushToken> findAllByMemberUuidInAndIsPushEnabledTrue(Collection<UUID> memberUuids);

    List<MemberPushToken> findAllByMemberUuid(UUID memberUuid);

    long countByIsPushEnabledTrue();

    @Modifying
    @Query("delete from MemberPushToken t where t.memberUuid = :memberUuid and t.token = :token")
    int deleteByMemberUuidAndToken(@Param("memberUuid") UUID memberUuid, @Param("token") String token);

    @Modifying
    @Query("delete from MemberPushToken t where t.memberUuid = :memberUuid")
    int deleteAllByMemberUuid(@Param("memberUuid") UUID memberUuid);

    @Modifying
    @Query("delete from MemberPushToken t where t.token in :tokens")
    int deleteAllByTokenIn(@Param("tokens") Collection<String> tokens);
}
